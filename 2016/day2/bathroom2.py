from typing import List, Tuple

Move = Tuple[int, int]
Pos = Tuple[int, int]

MOVES = {
  'U': (0, -1),
  'L': (-1, 0),
  'R': (1, 0),
  'D': (0, 1)
}

KEYPAD = [
  [None, None, '5', None, None],
  [None, '2', '6', 'A', None],
  ['1', '3', '7', 'B', 'D'],
  [None, '4', '8', 'C', None],
  [None, None, '9', None, None]
]

INITIAL_POS = (0, 2)

def get_moves(file: str) -> List[List[Move]]:
  with open(file, 'r') as f:
    lines = f.readlines()
    return list(map(lambda l: list(map(lambda c: MOVES[c], l.strip())), lines))

def within_bounds(n: int) -> int:
  if n < 0:
    return 0
  elif n > 4:
    return 4
  return n

def within_keypad_bounds(current: Pos, pos: Pos) -> Pos:
  if KEYPAD[pos[0]][pos[1]]:
    return pos
  return current

def apply_moves(pos: Pos, moves: List[Move]) -> Pos:
  for m in moves:
    x = within_bounds(pos[0] + m[0])
    y = within_bounds(pos[1] + m[1])
    pos = within_keypad_bounds(pos, (x, y))
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
