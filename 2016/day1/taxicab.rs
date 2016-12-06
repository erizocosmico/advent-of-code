use std::io::prelude::*;
use std::fs::File;
use std::str::from_utf8;

enum Dir {
    N, E, S, W
}

enum Movement {
    Right(i32),
    Left(i32),
}

struct Map {
    x: i32,
    y: i32,
    dir: Dir
}

impl Map {
    fn new() -> Map {
        Map{x: 0, y: 0, dir: Dir::N}
    }

    fn move(&self, i: Movement) -> Map {
        let (dir, n) = match i {
            Movement::Right(n) => match self.dir {
                Dir::N => (Dir::E, n),
                Dir::E => (Dir::S, n),
                Dir::S => (Dir::W, n),
                Dir::W => (Dir::N, n)
            },
            Movement::Left(n) => match self.dir {
                Dir::N => (Dir::W, n),
                Dir::W => (Dir::S, n),
                Dir::S => (Dir::E, n),
                Dir::E => (Dir::N, n),
            }
        };

        let (delta_x, delta_y) = match dir {
            Dir::N => (0, n),
            Dir::W => (-n, 0),
            Dir::S => (0, -n),
            Dir::E => (n, 0)
        };
        
        Map{x: self.x + delta_x, y: self.y + delta_y, dir: dir}
    }

    fn distance(&self) -> i32 {
        self.x.abs() + self.y.abs()
    }
}

fn main() {
    let mut f = File::open("data.txt").expect("unable to open file");
    let mut data = String::new();
    f.read_to_string(&mut data).expect("unable to read file");

    let map = data
        .split(", ")
        .map(|s| s.trim())
        .map(|m| {
            let bytes = m.as_bytes();
            let (first, rest) = bytes.split_at(1);
            let n: i32 = from_utf8(rest).unwrap().parse().unwrap();
            match first[0] as char {
                'R' => Movement::Right(n),
                'L' => Movement::Left(n),
                d => panic!("invalid instruction direction {}", d)
            }
        })
        .fold(Map::new(), |map, mov| map.move(mov));
    println!("{}", map.distance());
}
