package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func isIP(l string) bool {
	var (
		hasABBA       bool
		isHypernetSeq bool
		prev          rune
		size          = len(l)
	)

	for i, r := range l {
		if r == '[' {
			isHypernetSeq = true
		} else if r == ']' {
			isHypernetSeq = false
		}

		if prev != r && i+2 < size && prev == rune(l[i+2]) && r == rune(l[i+1]) {
			if isHypernetSeq {
				return false
			}
			hasABBA = true
		}

		prev = r
	}

	return hasABBA
}

func main() {
	data, err := ioutil.ReadFile("./data.txt")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(data), "\n")
	var ips int
	for _, l := range lines {
		if isIP(l) {
			fmt.Println(l)
			ips++
		}
	}

	fmt.Println(ips)
}
