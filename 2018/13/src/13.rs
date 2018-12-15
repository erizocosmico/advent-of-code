use std::collections::HashMap;
use std::collections::HashSet;

type Map = HashMap<(usize, usize), char>;

struct Cart {
    x: usize,
    y: usize,
    dir: char,
    intersections: usize,
    dead: bool,
}

impl Cart {
    fn new(x: usize, y: usize, dir: char, intersections: usize, dead: bool) -> Cart {
        Cart {
            x: x,
            y: y,
            dir: dir,
            intersections: intersections,
            dead: dead,
        }
    }
}

fn movement(dir: char) -> (isize, isize) {
    match dir {
        'v' => (0, 1),
        '^' => (0, -1),
        '<' => (-1, 0),
        '>' => (1, 0),
        d => panic!("invalid direction {}", d),
    }
}

fn next_direction(path: char, dir: char, intersections: usize) -> char {
    match (path, dir) {
        ('/', '<') => 'v',
        ('/', '^') => '>',
        ('/', '>') => '^',
        ('/', 'v') => '<',
        ('\\', '>') => 'v',
        ('\\', '^') => '<',
        ('\\', 'v') => '>',
        ('\\', '<') => '^',
        ('-', '<') => '<',
        ('-', '>') => '>',
        ('|', '^') => '^',
        ('|', 'v') => 'v',
        ('+', '<') => match intersections % 3 {
            0 => 'v',
            1 => '<',
            2 => '^',
            _ => panic!("unreachable"),
        },
        ('+', '>') => match intersections % 3 {
            0 => '^',
            1 => '>',
            2 => 'v',
            _ => panic!("unreachable"),
        },
        ('+', '^') => match intersections % 3 {
            0 => '<',
            1 => '^',
            2 => '>',
            _ => panic!("unreachable"),
        },
        ('+', 'v') => match intersections % 3 {
            0 => '>',
            1 => 'v',
            2 => '<',
            _ => panic!("unreachable"),
        },
        (a, b) => panic!("invalid state ({}, {})", a, b),
    }
}

fn move_carts(map: &Map, carts: &Vec<Cart>) -> Vec<Cart> {
    let mut positions: HashSet<_> = carts.into_iter().map(|c| (c.x, c.y)).collect();
    carts
        .into_iter()
        .map(|c| {
            let path = *map.get(&(c.x, c.y)).unwrap();
            let dir = next_direction(path, c.dir, c.intersections);
            let (dx, dy) = movement(dir);

            let x = (c.x as isize + dx) as usize;
            let y = (c.y as isize + dy) as usize;

            positions.remove(&(c.x, c.y));

            let nc = Cart::new(
                (c.x as isize + dx) as usize,
                (c.y as isize + dy) as usize,
                dir,
                c.intersections + if path == '+' { 1 } else { 0 },
                positions.contains(&(x, y)),
            );

            positions.insert((x, y));
            nc
        })
        .collect()
}

fn sort_cart(a: &Cart, b: &Cart) -> std::cmp::Ordering {
    match a.y.cmp(&b.y) {
        std::cmp::Ordering::Equal => a.x.cmp(&b.x),
        x => x,
    }
}

fn find_crash(carts: &Vec<Cart>) -> Option<(usize, usize)> {
    for c in carts {
        if c.dead {
            return Some((c.x, c.y));
        }
    }
    None
}

fn solve(input: String) -> (usize, usize) {
    let mut map = HashMap::new();
    let mut carts = Vec::new();
    for (y, line) in input.split("\n").enumerate() {
        for (x, ch) in line.chars().enumerate() {
            map.insert(
                (x, y),
                match ch {
                    '<' | '>' => {
                        carts.push(Cart::new(x, y, ch, 0, false));
                        '-'
                    }
                    '^' | 'v' => {
                        carts.push(Cart::new(x, y, ch, 0, false));
                        '|'
                    }
                    c => c,
                },
            );
        }
    }

    (&mut carts).sort_by(sort_cart);

    loop {
        carts = move_carts(&map, &carts);
        (&mut carts).sort_by(sort_cart);
        match find_crash(&carts) {
            Some((x, y)) => return (x, y),
            _ => (),
        }
    }
}

fn main() {
    let (x, y) = solve(include_str!("input.txt").into());
    println!("{},{}", x, y);
}

#[test]
fn test_13() {
    let input = vec![
        "/->-\\",
        "|   |  /----\\",
        "| /-+--+-\\  |",
        "| | |  | v  |",
        "\\-+-/  \\-+--/",
        "  \\------/",
    ];

    let result = solve(input.join("\n").into());
    assert_eq!(result, (7, 3));
}
