package main

import (
	"crypto/md5"
	"fmt"
	"strconv"
	"strings"
)

const input = "abbhdwsy"

func hash(n uint64) string {
	return fmt.Sprintf("%x", md5.Sum([]byte(fmt.Sprintf("%s%d", input, n))))
}

func main() {
	var idx uint64
	var password = make([]byte, 8)
	var filled int

	for filled < 8 {
		h := hash(idx)
		if strings.HasPrefix(h, "00000") {
			n, err := strconv.Atoi(h[5:6])
			if err != nil {
				n = -1
			}

			if n >= 0 && n <= 7 && password[n] == 0 {
				password[n] = h[6]
				filled++
			}
		}
		idx++
	}

	fmt.Println(string(password))
}
