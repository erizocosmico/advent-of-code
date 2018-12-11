fn power_level(x: usize, y: usize, serial: i32) -> i32 {
    let rack_id = x as i32 + 10;
    let n = (rack_id * y as i32 + serial) * rack_id;
    ((n / 100) % 10) - 5
}

// see: https://en.wikipedia.org/wiki/Summed-area_table#The_algorithm
fn solve(serial: i32) -> (usize, usize, usize) {
    let mut grid = [[0; 301]; 301];
    for y in 1..=300 {
        for x in 1..=300 {
            grid[x][y] =
                power_level(x, y, serial) + grid[x][y - 1] + grid[x - 1][y] - grid[x - 1][y - 1];
        }
    }

    let mut best_x = 0;
    let mut best_y = 0;
    let mut best_size = 0;
    let mut best_power = 0;

    for size in 1..=300 {
        for y in size..=300 {
            for x in size..=300 {
                let (x0, y0, x1, y1) = (x, y, x - size, y - size);
                let (a, b, c, d) = ((x0, y0), (x1, y0), (x0, y1), (x1, y1));
                let power = grid[d.0][d.1] + grid[a.0][a.1] - grid[b.0][b.1] - grid[c.0][c.1];

                if power > best_power {
                    best_power = power;
                    best_x = x1;
                    best_y = y1;
                    best_size = size;
                }
            }
        }
    }

    (best_x + 1, best_y + 1, best_size)
}

fn main() {
    let (x, y, size) = solve(7989);
    println!("{},{},{}", x, y, size);
}

#[test]
fn test_11b() {
    assert_eq!(solve(42), (232, 251, 12));
    assert_eq!(solve(18), (90, 269, 16));
}

#[test]
fn test_power_level() {
    assert_eq!(power_level(3, 5, 8), 4);
    assert_eq!(power_level(122, 79, 57), -5);
    assert_eq!(power_level(217, 196, 39), 0);
    assert_eq!(power_level(101, 153, 71), 4);
}
