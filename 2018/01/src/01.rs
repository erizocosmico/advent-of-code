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

fn calculate_frequency(input: String) -> i32 {
    input
        .split("\n")
        .map(|x| x.parse::<i32>().unwrap())
        .fold(0, |acc, x| acc + x)
}

fn main() {
    println!("{}", calculate_frequency(read_input()));
}

#[test]
fn test_01() {
    assert_eq!(calculate_frequency("+1\n+1\n+1".into()), 3);
    assert_eq!(calculate_frequency("+1\n+1\n-2".into()), 0);
    assert_eq!(calculate_frequency("-1\n-2\n-3".into()), -6);
}
