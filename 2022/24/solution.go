package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

type Direction int

const (
	Up Direction = iota + 1
	Down
	Left
	Right
)

type Blizzard struct {
	src Point
	dir Direction
}

func (b Blizzard) After(height, width, minutes int) Point {
	h, w := height-2, width-2
	x, y := b.src.X-1, b.src.Y-1

	switch b.dir {
	case Up:
		y = (y - minutes) % h
	case Down:
		y = (y + minutes) % h
	case Left:
		x = (x - minutes) % w
	case Right:
		x = (x + minutes) % w
	}

	if y < 0 {
		y = h + y
	}

	if x < 0 {
		x = w + x
	}

	return Point{X: x + 1, Y: y + 1}
}

type Map struct {
	start           Point
	end             Point
	width, height   int
	blizzardColumns map[int][]Blizzard
	blizzardRows    map[int][]Blizzard
}

type Point struct {
	X, Y int
}

func (m Map) JourneyDuration(start, end Point, offset int) int {
	var dp = make([][]int, m.height)
	for y := 0; y < m.height; y++ {
		dp[y] = make([]int, m.width)
		for x := 0; x < m.width; x++ {
			if !(y == start.Y && x == start.X) {
				dp[y][x] = -1
			}
		}
	}

	var t = 0
	for {
		if d := dp[end.Y][end.X]; d >= 0 {
			return d
		}

		var q []Point
		for y := 0; y < m.height; y++ {
			for x := 0; x < m.width; x++ {
				if dp[y][x] == t {
					for _, p := range m.movements(Point{x, y}, t+offset+1) {
						q = append(q, p)
					}
				}
			}
		}

		for _, p := range q {
			dp[p.Y][p.X] = t + 1
		}

		t++
	}
}

func (m Map) hasBlizzards(p Point, minutes int) bool {
	for _, b := range m.blizzardRows[p.Y] {
		if b.After(m.height, m.width, minutes) == p {
			return true
		}
	}

	for _, b := range m.blizzardColumns[p.X] {
		if b.After(m.height, m.width, minutes) == p {
			return true
		}
	}

	return false
}

var moves = [][2]int{
	{-1, 0},
	{1, 0},
	{0, -1},
	{0, 1},
	{0, 0},
}

func (m Map) movements(p Point, minutes int) []Point {
	var result []Point

	for _, n := range moves {
		np := Point{X: p.X + n[0], Y: p.Y + n[1]}
		if (np.X < 1 || np.X >= m.width-1 || np.Y < 1 || np.Y >= m.height-1) && np != m.start && np != m.end {
			continue
		}

		if !m.hasBlizzards(np, minutes) {
			result = append(result, np)
		}
	}

	return result
}

func parseMap() (*Map, error) {
	f, err := ioutil.ReadFile("input.txt")
	if err != nil {
		return nil, fmt.Errorf("could not read file: %w", err)
	}

	lines := bytes.Split(f, []byte("\n"))
	m := &Map{
		width:           len(lines[0]),
		height:          len(lines),
		start:           Point{X: 1, Y: 0},
		end:             Point{X: len(lines[0]) - 2, Y: len(lines) - 1},
		blizzardColumns: make(map[int][]Blizzard),
		blizzardRows:    make(map[int][]Blizzard),
	}

	for y, line := range lines {
		for x, c := range line {
			switch c {
			case '<':
				m.blizzardRows[y] = append(m.blizzardRows[y], Blizzard{src: Point{X: x, Y: y}, dir: Left})
			case '>':
				m.blizzardRows[y] = append(m.blizzardRows[y], Blizzard{src: Point{X: x, Y: y}, dir: Right})
			case '^':
				m.blizzardColumns[x] = append(m.blizzardColumns[x], Blizzard{src: Point{X: x, Y: y}, dir: Up})
			case 'v':
				m.blizzardColumns[x] = append(m.blizzardColumns[x], Blizzard{src: Point{X: x, Y: y}, dir: Down})
			}
		}
	}

	return m, nil
}

func main() {
	m, err := parseMap()
	if err != nil {
		log.Fatal(err)
		os.Exit(1)
	}

	j1 := m.JourneyDuration(m.start, m.end, 0)
	j2 := m.JourneyDuration(m.end, m.start, j1)
	j3 := m.JourneyDuration(m.start, m.end, j1+j2)

	fmt.Println("Part one:", j1)
	fmt.Println("Part two:", j1+j2+j3)
}
