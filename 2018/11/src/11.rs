fn power_level(x: i32, y: i32, serial: i32) -> i32 {
    let rack_id = x + 10;
    let n = (rack_id * y + serial) * rack_id;
    ((n / 100) % 10) - 5
}

fn grid_power(x: i32, y: i32, serial: i32) -> i32 {
    let mut power = 0;
    for dy in 0..3 {
        for dx in 0..3 {
            power += power_level(x + dx, y + dy, serial);
        }
    }
    power
}

fn solve(serial: i32) -> (i32, i32) {
    let mut grids = Vec::new();
    for y in 1..=298 {
        for x in 1..=298 {
            grids.push((x, y, grid_power(x, y, serial)));
        }
    }

    let (x, y, _) = grids
        .into_iter()
        .max_by(|(_, _, p1), (_, _, p2)| p1.cmp(p2))
        .unwrap();
    (x, y)
}

fn main() {
    let (x, y) = solve(7989);
    println!("{},{}", x, y);
}

#[test]
fn test_11() {
    assert_eq!(solve(42), (21, 61));
    assert_eq!(solve(18), (33, 45));
}

#[test]
fn test_power_level() {
    assert_eq!(power_level(3, 5, 8), 4);
    assert_eq!(power_level(122, 79, 57), -5);
    assert_eq!(power_level(217, 196, 39), 0);
    assert_eq!(power_level(101, 153, 71), 4);
}
