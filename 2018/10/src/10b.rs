#[macro_use]
extern crate lazy_static;
extern crate regex;

use regex::Regex;
use std::cmp::max;
use std::cmp::min;
use std::i32::MAX;

fn solve(input: String) -> i32 {
    lazy_static! {
        static ref RE: Regex =
            Regex::new(r"^position=< ?(-?\d+), *(-?\d+)> velocity=< ?(-?\d+), *(-?\d+)>$").unwrap();
    }
    let points: Vec<((i32, i32), (i32, i32))> = input
        .split("\n")
        .map(|l| {
            let c = RE.captures(l).unwrap();
            (
                (
                    c.get(1).unwrap().as_str().parse::<i32>().unwrap(),
                    c.get(2).unwrap().as_str().parse::<i32>().unwrap(),
                ),
                (
                    c.get(3).unwrap().as_str().parse::<i32>().unwrap(),
                    c.get(4).unwrap().as_str().parse::<i32>().unwrap(),
                ),
            )
        })
        .collect();

    let (sec, _) = (0..25000)
        .map(|sec| {
            let mut max_x = 0;
            let mut max_y = 0;
            let mut min_x = MAX;
            let mut min_y = MAX;

            for ((x, y), (vx, vy)) in &points {
                let new_x = x + vx * sec;
                let new_y = y + vy * sec;
                max_x = max(new_x, max_x);
                max_y = max(new_y, max_y);
                min_x = min(new_x, min_x);
                min_y = min(new_y, min_y);
            }

            (sec, max_x - min_x + max_y - min_y)
        })
        .min_by(|(_, d1), (_, d2)| d1.cmp(d2))
        .unwrap();

    sec
}

fn main() {
    println!("{}", solve(include_str!("input.txt").into()));
}

#[test]
fn test_10b() {
    let input = vec![
        "position=< 9,  1> velocity=< 0,  2>",
        "position=< 7,  0> velocity=<-1,  0>",
        "position=< 3, -2> velocity=<-1,  1>",
        "position=< 6, 10> velocity=<-2, -1>",
        "position=< 2, -4> velocity=< 2,  2>",
        "position=<-6, 10> velocity=< 2, -2>",
        "position=< 1,  8> velocity=< 1, -1>",
        "position=< 1,  7> velocity=< 1,  0>",
        "position=<-3, 11> velocity=< 1, -2>",
        "position=< 7,  6> velocity=<-1, -1>",
        "position=<-2,  3> velocity=< 1,  0>",
        "position=<-4,  3> velocity=< 2,  0>",
        "position=<10, -3> velocity=<-1,  1>",
        "position=< 5, 11> velocity=< 1, -2>",
        "position=< 4,  7> velocity=< 0, -1>",
        "position=< 8, -2> velocity=< 0,  1>",
        "position=<15,  0> velocity=<-2,  0>",
        "position=< 1,  6> velocity=< 1,  0>",
        "position=< 8,  9> velocity=< 0, -1>",
        "position=< 3,  3> velocity=<-1,  1>",
        "position=< 0,  5> velocity=< 0, -1>",
        "position=<-2,  2> velocity=< 2,  0>",
        "position=< 5, -2> velocity=< 1,  2>",
        "position=< 1,  4> velocity=< 2,  1>",
        "position=<-2,  7> velocity=< 2, -2>",
        "position=< 3,  6> velocity=<-1, -1>",
        "position=< 5,  0> velocity=< 1,  0>",
        "position=<-6,  0> velocity=< 2,  0>",
        "position=< 5,  9> velocity=< 1, -2>",
        "position=<14,  7> velocity=<-2,  0>",
        "position=<-3,  6> velocity=< 2, -1>",
    ];
    let result = solve(input.join("\n").into());
    assert_eq!(result, 3);
}
