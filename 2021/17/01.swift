let target = (x: 56 ... 76, y: -162 ... -134)

let initialY = abs(target.y.min()!) - 1
let maxHeight = (initialY + 1) * initialY / 2
print("*", maxHeight)

func isOutOfRange(_ x: Int, _ y: Int) -> Bool {
	return x > target.x.max()! || y < target.y.min()!
}

func reachesTarget(_ velx: Int, _ vely: Int) -> Bool {
	var (x, y) = (0, 0)
	var (dx, dy) = (velx, vely)
	while !isOutOfRange(x, y) {
		x += dx
		y += dy

		if target.x.contains(x), target.y.contains(y) {
			return true
		}

		dy -= 1
		dx = dx > 0 ? dx - 1 : 0
	}
	return false
}

var result = 0
for velx in 0 ... target.x.max()! {
	for vely in target.y.min()! ... abs(target.y.min()!) {
		if reachesTarget(velx, vely) {
			result += 1
		}
	}
}

print("**", result)
