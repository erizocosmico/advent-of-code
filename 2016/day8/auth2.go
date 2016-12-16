package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"regexp"
	"strconv"
	"strings"
)

type Pixel bool

const (
	On  Pixel = true
	Off Pixel = false
)

type Screen [6][50]Pixel

var (
	rectRegex   = regexp.MustCompile(`^rect (\d+)x(\d+)`)
	rotateRegex = regexp.MustCompile(`^rotate (column|row) (x|y)=(\d+) by (\d+)`)
)

func (s *Screen) Execute(ins string) {
	if strings.HasPrefix(ins, "rect") {
		parts := rectRegex.FindStringSubmatch(ins)
		s.Rect(toInt(parts[1]), toInt(parts[2]))
	} else if strings.HasPrefix(ins, "rotate") {
		parts := rotateRegex.FindStringSubmatch(ins)
		if parts[1] == "column" {
			s.RotateColumn(toInt(parts[3]), toInt(parts[4]))
		} else if parts[1] == "row" {
			s.RotateRow(toInt(parts[3]), toInt(parts[4]))
		}
	}
}

func (s *Screen) Set(i, j int, state Pixel) {
	(*s)[i][j] = state
}

func (s *Screen) Rect(a, b int) {
	for i := 0; i < b; i++ {
		for j := 0; j < a; j++ {
			s.Set(i, j, On)
		}
	}
}

func (s *Screen) RotateColumn(col, n int) {
	var tmp [6]Pixel
	for i, r := range *s {
		tmp[(i+n)%6] = r[col]
	}

	for i, state := range tmp {
		s.Set(i, col, state)
	}
}

func (s *Screen) RotateRow(row, n int) {
	var tmp [50]Pixel
	for i, p := range (*s)[row] {
		tmp[(i+n)%50] = p
	}

	for i, state := range tmp {
		s.Set(row, i, state)
	}
}

func (s Screen) NumPixelsLit() (pixels int) {
	for _, r := range s {
		for _, c := range r {
			if c == On {
				pixels++
			}
		}
	}
	return
}

func (s Screen) String() string {
	var buf bytes.Buffer
	for _, row := range s {
		for _, col := range row {
			if col == On {
				buf.WriteRune('#')
			} else {
				buf.WriteRune(' ')
			}
		}
		buf.WriteRune('\n')
	}
	return buf.String()
}

func toInt(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}

func main() {
	data, err := ioutil.ReadFile("./data.txt")
	if err != nil {
		panic(err)
	}

	instructions := strings.Split(string(data), "\n")
	screen := Screen{}
	for _, i := range instructions {
		screen.Execute(i)
	}

	fmt.Println(screen.String())
}
