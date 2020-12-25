import Foundation

func findLoopSize(_ key: Int) -> Int {
  var loopSize = 0
  var n = 1
  while n != key {
    n = (n * 7) % 20_201_227
    loopSize += 1
  }
  return loopSize
}

func generateEncryptionKey(_ subject: Int, _ loopSize: Int) -> Int {
  var n = 1
  for _ in 1...loopSize {
    n = (n * subject) % 20_201_227
  }
  return n
}

let cardPublicKey = 6_270_530
let doorPublicKey = 14_540_258

let cardLoopSize = findLoopSize(cardPublicKey)
let doorLoopSize = findLoopSize(doorPublicKey)

let cardEncryptionKey = generateEncryptionKey(cardPublicKey, doorLoopSize)
let doorEncryptionKey = generateEncryptionKey(doorPublicKey, cardLoopSize)

if cardEncryptionKey == doorEncryptionKey {
  print(cardEncryptionKey)
}
