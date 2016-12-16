package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
	"unicode"
)

func toInt(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}

func DecompressedSize(reader *bufio.Reader) (int, error) {
	var size int
	for {
		b, err := reader.ReadByte()
		if err == io.EOF {
			break
		} else if err != nil {
			panic(err)
		}

		switch r := rune(b); true {
		case r == '(':
			bs, err := reader.ReadBytes(byte('x'))
			if err != nil {
				return 0, err
			}
			chars := toInt(strings.TrimRight(string(bs), "x"))

			bs, err = reader.ReadBytes(byte(')'))
			if err != nil {
				return 0, err
			}
			times := toInt(strings.TrimRight(string(bs), ")"))

			var buf = bytes.NewBuffer(nil)
			_, err = io.CopyN(buf, reader, int64(chars))
			if err != nil {
				return 0, err
			}

			dataSize, err := DecompressedSize(bufio.NewReader(buf))
			if err != nil {
				return 0, err
			}

			size += dataSize * times
		case unicode.IsSpace(r) || r == '\n' || r == '\r':
		default:
			size++
		}
	}
	return size, nil
}

func main() {
	f, err := os.Open("./data.txt")
	if err != nil {
		panic(err)
	}

	reader := bufio.NewReader(f)
	size, err := DecompressedSize(reader)
	if err != nil {
		panic(err)
	}
	fmt.Println(size)
}
