from __future__ import print_function, with_statement
from hashlib import md5

def hashnum_gen(key):
  i = 0
  while True:
    h = md5("%s%d" % (key, i)).hexdigest()
    yield h, i
    i += 1


def main():
  for h, i in hashnum_gen("ckczppom"):
    if h.startswith("00000"):
      print("> %d" % i)
      break


if __name__ == '__main__':
  main()
