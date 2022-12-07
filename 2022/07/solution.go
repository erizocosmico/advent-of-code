package main

import (
	"bufio"
	"bytes"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

func main() {
	fs, err := readFileSystem()
	if err != nil {
		log.Fatal(err)
		os.Exit(1)
	}

	sizes := CalculateDirectorySizes(fs)

	fmt.Println("Part one:", sizeOfDirectoriesUpTo(sizes, 100000))
	fmt.Println("Part two:", findDirectoryToDelete(sizes, 70000000, 30000000))
}

func findDirectoryToDelete(sizes map[string]uint64, total, required uint64) uint64 {
	remaining := total - sizes["/"]
	var current uint64
	for _, size := range sizes {
		if remaining+size >= required {
			if current == 0 {
				current = size
			} else if size < current {
				current = size
			}
		}
	}
	return current
}

func CalculateDirectorySizes(e *Entry) map[string]uint64 {
	var result = make(map[string]uint64)
	calculateDirectorySizes(e, result, "")
	return result
}

func calculateDirectorySizes(e *Entry, sizes map[string]uint64, path string) uint64 {
	var total uint64
	p := filepath.Join(path, e.Name)
	for _, c := range e.Children {
		if c.IsDir {
			total += calculateDirectorySizes(c, sizes, p)
		} else {
			total += c.Size
		}
	}
	sizes[p] = total
	return total
}

func sizeOfDirectoriesUpTo(sizes map[string]uint64, threshold uint64) uint64 {
	var result uint64

	for _, size := range sizes {
		if size <= threshold {
			result += size
		}
	}

	return result
}

type Entry struct {
	Name     string
	Size     uint64
	IsDir    bool
	Parent   *Entry
	Children []*Entry
}

func readFileSystem() (*Entry, error) {
	f, err := ioutil.ReadFile("input.txt")
	if err != nil {
		return nil, fmt.Errorf("could not read file: %w", err)
	}

	var root *Entry
	var current *Entry
	r := bufio.NewReader(bytes.NewReader(f))
	for {
		ln, _, err := r.ReadLine()
		if err != nil {
			if errors.Is(err, io.EOF) {
				break
			}
			return nil, fmt.Errorf("could not read line: %w", err)
		}
		line := string(ln)

		if strings.HasPrefix(line, "$ cd") {
			dir := strings.TrimPrefix(line, "$ cd ")
			switch dir {
			case "/":
				current = &Entry{Name: dir, IsDir: true}
				root = current
			case "..":
				current = current.Parent
			default:
				for _, e := range current.Children {
					if e.IsDir && e.Name == dir {
						current = e
						break
					}
				}
			}
		} else if strings.HasPrefix(line, "dir") {
			parts := strings.Split(line, " ")
			current.Children = append(current.Children, &Entry{Parent: current, Name: parts[1], IsDir: true})
		} else if !strings.HasPrefix(line, "$") {
			parts := strings.Split(line, " ")
			size, err := strconv.ParseUint(parts[0], 10, 64)
			if err != nil {
				return nil, fmt.Errorf("could not parse size: %w", err)
			}
			current.Children = append(current.Children, &Entry{Parent: current, Name: parts[1], Size: size})
		}
	}

	return root, nil
}
