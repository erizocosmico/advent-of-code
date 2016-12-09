package main

import (
	"crypto/md5"
	"fmt"
	"strings"
)

const input = "abbhdwsy"

func hash(n uint64) string {
	return fmt.Sprintf("%x", md5.Sum([]byte(fmt.Sprintf("%s%d", input, n))))
}

func main() {
	var idx uint64
	var password []byte

	for len(password) < 8 {
		h := hash(idx)
		if strings.HasPrefix(h, "00000") {
			password = append(password, h[5])
		}
		idx++
	}

	fmt.Println(string(password))
}
