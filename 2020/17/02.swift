import Foundation

typealias Grid4D = [[[[Int]]]]

func parseInput(_ s: String) -> Grid4D {
  let grid2d = s.components(separatedBy: "\n").map { line in
    return Array(line.map { ch in ch == Character("#") ? 1 : 0 })
  }
  return [[grid2d]]
}

func activeNeighbours(of: (Int, Int, Int, Int), prevState: Grid4D) -> Int {
  let maxw = prevState.count
  let maxz = prevState[0].count
  let maxxy = prevState[0][0].count
  var actives = 0

  for dw in -1...1 {
    for dz in -1...1 {
      for dy in -1...1 {
        for dx in -1...1 {
          let (x, y, z, w) = (of.0 + dx, of.1 + dy, of.2 + dz, of.3 + dw)
          if x < 0 || y < 0 || z < 0 || w < 0
            || w >= maxw || z >= maxz || x >= maxxy || y >= maxxy
            || (dx == 0 && dz == 0 && dy == 0 && dw == 0)
          {
            continue
          }

          actives += prevState[w][z][y][x]
        }
      }
    }
  }

  return actives
}

func boot(_ prevState: Grid4D, cycles: Int) -> Grid4D {
  if cycles == 0 {
    return prevState
  }

  // Even though the cube is expanded by 1 in each direction, in the first cycle
  // there should be no x, y expansion. But it's ok, it takes out some cases just
  // for that cycle.
  let x = Array(repeatElement(0, count: prevState[0][0].count + 2))
  let y = Array(repeatElement(x, count: prevState[0][0].count + 2))
  let z = Array(repeatElement(y, count: prevState[0].count + 2))
  var nextState: Grid4D = Array(repeatElement(z, count: prevState.count + 2))

  // Expand the previous state into the new size because otherwise the coordinates
  // of the neighbours won't be ok for the prev state size. It's not the most
  // performant solution, but it makes it easier to find the active neighbours
  // so ¯\_(ツ)_/¯.
  var current = nextState
  for w in 0..<prevState.count {
    for z in 0..<prevState[0].count {
      for y in 0..<prevState[0][0].count {
        for x in 0..<prevState[0][0].count {
          current[w + 1][z + 1][y + 1][x + 1] = prevState[w][z][y][x]
        }
      }
    }
  }

  for w in 0..<nextState.count {
    for z in 0..<nextState[0].count {
      for y in 0..<nextState[0][0].count {
        for x in 0..<nextState[0][0].count {
          let actives = activeNeighbours(of: (x, y, z, w), prevState: current)
          if current[w][z][y][x] == 1 && (2...3).contains(actives) {
            nextState[w][z][y][x] = 1
          } else if current[w][z][y][x] == 0 && actives == 3 {
            nextState[w][z][y][x] = 1
          }
        }
      }
    }
  }

  return boot(nextState, cycles: cycles - 1)
}

let initialState = parseInput(try String(contentsOfFile: "./input.txt", encoding: .utf8))

let state = boot(initialState, cycles: 6)
var actives = 0
for w in 0..<state.count {
  for z in 0..<state[0].count {
    for y in 0..<state[0][0].count {
      for x in 0..<state[0][0].count {
        actives += state[w][z][y][x]
      }
    }
  }
}

print(actives)
