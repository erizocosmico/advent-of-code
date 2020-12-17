import Foundation

typealias Grid3D = [[[Int]]]

func parseInput(_ s: String) -> Grid3D {
  let grid2d = s.components(separatedBy: "\n").map { line in
    return Array(line.map { ch in ch == Character("#") ? 1 : 0 })
  }
  return [grid2d]
}

func activeNeighbours(of: (Int, Int, Int), prevState: Grid3D) -> Int {
  let maxz = prevState.count
  let maxxy = prevState[0].count
  var actives = 0

  for dz in -1...1 {
    for dy in -1...1 {
      for dx in -1...1 {
        let (x, y, z) = (of.0 + dx, of.1 + dy, of.2 + dz)
        if x < 0 || y < 0 || z < 0 || z >= maxz || x >= maxxy || y >= maxxy
          || (dx == 0 && dz == 0 && dy == 0)
        {
          continue
        }

        actives += prevState[z][y][x]
      }
    }
  }

  return actives
}

func boot(_ prevState: Grid3D, cycles: Int) -> Grid3D {
  if cycles == 0 {
    return prevState
  }

  // Even though the cube is expanded by 1 in each direction, in the first cycle
  // there should be no x, y expansion. But it's ok, it takes out some cases just
  // for that cycle.
  let x = Array(repeatElement(0, count: prevState[0].count + 2))
  let y = Array(repeatElement(x, count: prevState[0].count + 2))
  var nextState: Grid3D = Array(repeatElement(y, count: prevState.count + 2))

  // Expand the previous state into the new size because otherwise the coordinates
  // of the neighbours won't be ok for the prev state size. It's not the most
  // performant solution, but it makes it easier to find the active neighbours
  // so ¯\_(ツ)_/¯.
  var current = nextState
  for z in 0..<prevState.count {
    for y in 0..<prevState[0].count {
      for x in 0..<prevState[0].count {
        current[z + 1][y + 1][x + 1] = prevState[z][y][x]
      }
    }
  }

  for z in 0..<nextState.count {
    for y in 0..<nextState[0].count {
      for x in 0..<nextState[0].count {
        let actives = activeNeighbours(of: (x, y, z), prevState: current)
        if current[z][y][x] == 1 && (2...3).contains(actives) {
          nextState[z][y][x] = 1
        } else if current[z][y][x] == 0 && actives == 3 {
          nextState[z][y][x] = 1
        }
      }
    }
  }

  return boot(nextState, cycles: cycles - 1)
}

let initialState = parseInput(try String(contentsOfFile: "./input.txt", encoding: .utf8))

let state = boot(initialState, cycles: 6)
var actives = 0
for z in 0..<state.count {
  for y in 0..<state[0].count {
    for x in 0..<state[0].count {
      actives += state[z][y][x]
    }
  }
}
print(actives)
