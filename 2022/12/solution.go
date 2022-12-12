package main

import (
	"bytes"
	"container/heap"
	"fmt"
	"io/ioutil"
	"log"
	"math"
	"os"
)

func main() {
	m, start, end, err := readInput()
	if err != nil {
		log.Fatal(err)
		os.Exit(1)
	}

	part1 := findShortestPath(m, start, end)
	fmt.Println("Part one:", part1)

	var part2 = math.MaxInt
	for y, row := range m {
		for x, height := range row {
			if height == 0 {
				v := findShortestPath(m, Point{X: x, Y: y}, end)
				if part2 > v {
					part2 = v
				}
			}
		}
	}
	fmt.Println("Part two:", part2)
}

func findShortestPath(m [][]int, start, end Point) int {
	visited := make(map[Point]struct{})
	paths := make(map[Point]int)
	for i, row := range m {
		for j := range row {
			if j != start.X || i != start.Y {
				paths[Point{X: j, Y: i}] = math.MaxInt
			}
		}
	}

	q := &PointQueue{
		points: []Point{start},
		paths:  paths,
	}

	for q.Len() > 0 {
		curr := heap.Pop(q).(Point)
		if curr == end {
			break
		}

		if _, ok := visited[curr]; ok {
			continue
		}

		for _, n := range neighbours(m, curr) {
			if _, ok := visited[n]; !ok {
				if q.paths[n] > q.paths[curr]+1 {
					q.paths[n] = q.paths[curr] + 1
				}
				heap.Push(q, n)
			}
		}

		visited[curr] = struct{}{}
	}

	return q.paths[end]
}

var adjacents = [][2]int{
	{0, -1},
	{-1, 0},
	{0, 1},
	{1, 0},
}

func neighbours(m [][]int, p Point) []Point {
	var result []Point
	var currentHeight = m[p.Y][p.X]

	for _, n := range adjacents {
		if p.X == 0 && n[0] < 0 ||
			p.Y == 0 && n[1] < 0 {
			continue
		}

		newx := p.X + n[0]
		newy := p.Y + n[1]

		if newx >= len(m[0]) || newy >= len(m) {
			continue
		}

		if m[newy][newx]-currentHeight > 1 {
			continue
		}

		result = append(result, Point{X: newx, Y: newy})
	}

	return result
}

type Point struct {
	X, Y int
}

func readInput() (m [][]int, start Point, end Point, err error) {
	f, err := ioutil.ReadFile("input.txt")
	if err != nil {
		return nil, start, end, fmt.Errorf("could not read file: %w", err)
	}

	lines := bytes.Split(f, []byte("\n"))
	m = make([][]int, len(lines))
	for i, line := range lines {
		m[i] = make([]int, len(line))
		for j, c := range line {
			switch c {
			case 'S':
				start = Point{X: j, Y: i}
				m[i][j] = 0
			case 'E':
				end = Point{X: j, Y: i}
				m[i][j] = 25
			default:
				m[i][j] = int(rune(c) - 'a')
			}
		}
	}

	return m, start, end, nil
}

type PointQueue struct {
	points []Point
	paths  map[Point]int
}

func (h PointQueue) Len() int           { return len(h.points) }
func (h PointQueue) Less(i, j int) bool { return h.paths[h.points[i]] < h.paths[h.points[j]] }
func (h PointQueue) Swap(i, j int)      { h.points[i], h.points[j] = h.points[j], h.points[i] }

func (h *PointQueue) Push(x any) {
	h.points = append(h.points, x.(Point))
}

func (h *PointQueue) Pop() any {
	old := h.points
	n := len(old)
	x := old[n-1]
	h.points = old[0 : n-1]
	return x
}
