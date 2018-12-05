use std::collections::HashSet;
use std::fs::File;
use std::io::prelude::*;

fn read_input() -> String {
    let mut contents = String::new();
    File::open("input.txt")
        .expect("input file not found")
        .read_to_string(&mut contents)
        .expect("unable to read file");
    contents
}

fn scanned_polymer_size(input: String) -> usize {
    let mut units: Vec<_> = input.chars().collect();
    let mut idx = 0;
    let mut current = *units.get(0).unwrap();
    while idx + 1 < units.len() {
        let next = *units.get(idx + 1).unwrap();

        if reacts(current, next) {
            units.remove(idx + 1);
            units.remove(idx);
            idx = if idx as i32 - 2 < 0 { 0 } else { idx - 2 };
            current = *units.get(idx).unwrap();
        } else {
            idx += 1;
            current = next;
        }
    }

    units.len()
}

fn reacts(a: char, b: char) -> bool {
    a != b && a.to_lowercase().to_string() == b.to_lowercase().to_string()
}

fn solve(input: String) -> usize {
    let chars: HashSet<_> = input.chars().flat_map(|c| c.to_lowercase()).collect();
    chars
        .into_iter()
        .map(|c| {
            input
                .replace(c.to_string().as_str(), "")
                .replace(c.to_uppercase().to_string().as_str(), "")
        })
        .map(scanned_polymer_size)
        .min()
        .unwrap()
}

fn main() {
    println!("{}", solve(read_input()));
}

#[test]
fn test_05b() {
    let input = "dabAcCaCBAcCcaDA".into();

    let result = solve(input);
    assert_eq!(result, 4);
}
