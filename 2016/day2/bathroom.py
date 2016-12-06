from typing import List, Tuple

Move = Tuple[int, int]
Pos = Tuple[int, int]

MOVES = {
  'U': (0, 1),
  'L': (-1, 0),
  'R': (1, 0),
  'D': (0, -1)
}

KEYPAD = [
  ['1', '4', '7'],
  ['2', '5', '8'],
  ['3', '6', '9']
]

INITIAL_POS = (1, 1)

def get_moves(file: str) -> List[List[Move]]:
  with open(file, 'r') as f:
    lines = f.readlines()
    return list(map(lambda l: list(map(lambda c: MOVES[c], l.strip())), lines))

def within_bounds(n: int) -> int:
  if n < 0:
    return 0
  elif n > 2:
    return 2
  return n

def apply_moves(pos: Pos, moves: List[Move]) -> Pos:
  for m in moves:
    x = within_bounds(pos[0] + m[0])
    y = within_bounds(pos[1] + m[1])
    pos = (x, y)
  return pos

def main():
  pos = INITIAL_POS
  nums = []
  for l in get_moves("data.txt"):
    pos = apply_moves(pos, l)
    nums.append(KEYPAD[pos[0]][pos[1]])
  print(''.join(nums))

if __name__ == '__main__':
  main()
