#[macro_use]
extern crate lazy_static;
extern crate regex;

use regex::Regex;
use std::cmp::max;
use std::cmp::min;
use std::collections::HashSet;
use std::i32::MAX;

fn main() {
    lazy_static! {
        static ref RE: Regex =
            Regex::new(r"^position=< ?(-?\d+), *(-?\d+)> velocity=< ?(-?\d+), *(-?\d+)>$").unwrap();
    }
    let points: Vec<((i32, i32), (i32, i32))> = include_str!("input.txt")
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

    let (sec, maxx, minx, maxy, miny) = (0..25000)
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

            (sec, max_x, min_x, max_y, min_y)
        })
        .min_by(
            |(_, maxx1, minx1, maxy1, miny1), (_, maxx2, minx2, maxy2, miny2)| {
                (maxx1 - minx1 + maxy1 - miny1).cmp(&(maxx2 - minx2 + maxy2 - miny2))
            },
        )
        .unwrap();

    let pts: HashSet<(i32, i32)> = points
        .into_iter()
        .map(|((x, y), (vx, vy))| (x + vx * sec, y + vy * sec))
        .collect();

    for y in miny..=maxy {
        for x in minx..=maxx {
            print!("{}", if pts.contains(&(x, y)) { "#" } else { "." });
        }
        println!("");
    }
}
