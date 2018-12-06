type Point = (i32, i32);

fn distance(a: Point, b: Point) -> i32 {
    (a.0 - b.0).abs() + (a.1 - b.1).abs()
}

fn input_points(input: String) -> Vec<Point> {
    input
        .split("\n")
        .map(|x| {
            let parts: Vec<_> = x.split(", ").collect();
            (
                parts.get(0).unwrap().parse::<i32>().unwrap(),
                parts.get(1).unwrap().parse::<i32>().unwrap(),
            )
        })
        .collect()
}

fn find_bounds(points: &Vec<Point>) -> ((i32, i32), (i32, i32)) {
    let min_x = points.into_iter().map(|x| x.0).min().unwrap();
    let max_x = points.into_iter().map(|x| x.0).max().unwrap();
    let min_y = points.into_iter().map(|x| x.1).min().unwrap();
    let max_y = points.into_iter().map(|x| x.1).max().unwrap();
    ((min_x, min_y), (max_x, max_y))
}

fn region_within(input: String, n: i32) -> i32 {
    let points = &input_points(input);
    let ((min_x, min_y), (max_x, max_y)) = find_bounds(points);

    let mut count = 0;
    for x in min_x..=max_x {
        for y in min_y..=max_y {
            let total_distance: i32 = points.into_iter().map(|p| distance((x, y), *p)).sum();
            if total_distance < n {
                count += 1;
            }
        }
    }

    count
}

fn main() {
    println!("{}", region_within(include_str!("input.txt").into(), 10000));
}

#[test]
fn test_06b() {
    let input = vec!["1, 1", "1, 6", "8, 3", "3, 4", "5, 5", "8, 9"];
    let result = region_within(input.join("\n").into(), 32);
    assert_eq!(result, 16);
}
