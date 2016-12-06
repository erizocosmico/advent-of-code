from __future__ import with_statement, print_function
from math import fabs
from typing import List, Tuple

Instruction = Tuple[str, int]
Dir = Tuple[int, int]

NORTH = (0, 1)
SOUTH = (0, -1)
EAST = (1, 0)
WEST = (-1, 0)

DIRS = [NORTH, EAST, SOUTH, WEST]

def move_right(dir: Dir) -> Dir:
  idx = DIRS.index(dir)
  if idx == len(DIRS)-1:
    return NORTH
  return DIRS[idx+1]

def move_left(dir: Dir) -> Dir:
  idx = DIRS.index(dir)
  if idx == 0:
    return WEST
  return DIRS[idx-1]

class Map(object):
  def __init__(self):
    self.visited = set()
    self.dir = NORTH
    self.pos = [0, 0]

  def move(self, i: Instruction) -> bool:
    self.dir = move_right(self.dir) if i[0] == 'R' else move_left(self.dir)
    for i in range(i[1]):
      if self.forward():
        return False
    return True

  def forward(self) -> bool:
    self.pos = [self.pos[0] + self.dir[0], self.pos[1] + self.dir[1]]
    exists = tuple(self.pos) in self.visited
    self.visited.add(tuple(self.pos))
    return exists

  def distance(self) -> int:
    return fabs(self.pos[0]) + fabs(self.pos[1])

def to_instruction(input: str) -> Instruction:
  return (input[0], int(input[1:]))

def get_instructions(file: str) -> List[Instruction]:
  with open(file, 'r') as f:
    data = f.read()
  return list(map(to_instruction, data.strip().split(', ')))

def main():
  m = Map()
  for i in get_instructions("data.txt"):
    if not m.move(i):
      break
  print(m.distance())

if __name__ == '__main__':
  main()
