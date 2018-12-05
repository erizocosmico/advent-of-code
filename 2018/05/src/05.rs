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

fn scan_polymer(input: String) -> String {
    let mut units = input.into_bytes();
    let mut idx = 0;
    let mut current = *units.get(0).unwrap() as char;
    while idx + 1 < units.len() {
        let next = *units.get(idx + 1).unwrap() as char;

        if reacts(current, next) {
            units.remove(idx + 1);
            units.remove(idx);
            idx = if idx as i32 - 2 < 0 { 0 } else { idx - 2 };
            current = *units.get(idx).unwrap() as char;
        } else {
            idx += 1;
            current = next;
        }
    }

    String::from_utf8(units).unwrap_or_default()
}

fn reacts(a: char, b: char) -> bool {
    a != b && a.to_lowercase().to_string() == b.to_lowercase().to_string()
}

fn main() {
    println!("{}", scan_polymer(read_input()).len());
}

#[test]
fn test_05() {
    let input = "dabAcCaCBAcCcaDA".into();

    let result = scan_polymer(input);
    assert_eq!(result.len(), 10);
}
