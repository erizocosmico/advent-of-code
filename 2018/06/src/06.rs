use std::collections::HashMap;
use std::collections::HashSet;

type Point = (i32, i32);

fn distance(a: Point, b: Point) -> i32 {
    (a.0 - b.0).abs() + (a.1 - b.1).abs()
}

fn closest(a: Point, all: &Vec<Point>) -> Point {
    let mut distances: Vec<_> = all.into_iter().map(|x| (x, distance(a, *x))).collect();
    (&mut distances).sort_by(|(_, d1), (_, d2)| d1.cmp(d2));
    let (p, d1) = *distances.get(0).unwrap();
    let (_, d2) = *distances.get(1).unwrap();
    if d1 < d2 {
        *p
    } else {
        (-1, -1)
    }
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

fn largest_area(input: String) -> i32 {
    let points = input_points(input);
    let ((min_x, min_y), (max_x, max_y)) = find_bounds(&points);

    let mut infinite = HashSet::new();
    let mut areas = HashMap::new();
    for x in min_x..=max_x {
        for y in min_y..=max_y {
            let (cx, cy) = closest((x, y), &points);
            if x == min_x || x == max_x || y == min_y || y == max_y {
                infinite.insert((cx, cy));
            }

            if cx >= 0 && cy >= 0 {
                *areas.entry((cx, cy)).or_insert(0) += 1;
            }
        }
    }

    for p in infinite {
        areas.remove(&p);
    }

    *areas.values().max().unwrap()
}

fn main() {
    println!("{}", largest_area(include_str!("input.txt").into()));
}

#[test]
fn test_06() {
    let input = vec!["1, 1", "1, 6", "8, 3", "3, 4", "5, 5", "8, 9"];
    let result = largest_area(input.join("\n").into());
    assert_eq!(result, 17);
}
