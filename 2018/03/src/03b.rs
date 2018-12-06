#[macro_use]
extern crate lazy_static;
extern crate itertools;
extern crate regex;

use itertools::Itertools;
use regex::Regex;
use std::collections::HashSet;

#[derive(Clone, Copy)]
struct Claim {
    id: i32,
    offset_left: i32,
    offset_top: i32,
    width: i32,
    height: i32,
}

impl Claim {
    fn parse(raw_claim: &str) -> Claim {
        lazy_static! {
            static ref CLAIM_REGEX: Regex =
                Regex::new(r"^#(\d+) @ (\d+),(\d+): (\d+)x(\d+)$").unwrap();
        }

        let captures = CLAIM_REGEX.captures(raw_claim).unwrap();
        Claim {
            id: captures.get(1).unwrap().as_str().parse::<i32>().unwrap(),
            offset_left: captures.get(2).unwrap().as_str().parse::<i32>().unwrap(),
            offset_top: captures.get(3).unwrap().as_str().parse::<i32>().unwrap(),
            width: captures.get(4).unwrap().as_str().parse::<i32>().unwrap(),
            height: captures.get(5).unwrap().as_str().parse::<i32>().unwrap(),
        }
    }

    fn coordinates(self) -> Vec<(i32, i32)> {
        let mut coords = Vec::new();
        for x in 0..self.width {
            for y in 0..self.height {
                coords.push((x + self.offset_left, y + self.offset_top));
            }
        }
        coords
    }
}

fn non_overlapping(input: String) -> i32 {
    let mut claims: Vec<Claim> = Vec::new();
    for raw_claim in input.split("\n") {
        claims.push(Claim::parse(raw_claim));
    }

    let coords = (&claims).into_iter().flat_map(|x| x.coordinates()).sorted();

    let mut overlaps = HashSet::new();

    let mut prev = (-1, -1);
    for c in coords {
        if prev == c {
            overlaps.insert(c);
        }

        prev = c;
    }

    claims
        .into_iter()
        .find(|x| x.coordinates().into_iter().all(|c| !overlaps.contains(&c)))
        .unwrap()
        .id
}

fn main() {
    let input = include_str!("input.txt").into();
    println!("{}", non_overlapping(input));
}

#[test]
fn test_03b() {
    let input = vec!["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"];

    let result = non_overlapping(input.join("\n"));
    assert_eq!(result, 3);
}
