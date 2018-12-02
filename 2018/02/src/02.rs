use std::collections::HashMap;
use std::fs::File;
use std::io::prelude::*;
use std::str::Chars;

fn read_input() -> String {
    let mut contents = String::new();
    File::open("input.txt")
        .expect("input file not found")
        .read_to_string(&mut contents)
        .expect("unable to read file");
    contents
}

fn frequencies(input: Chars) -> Vec<(char, i32)> {
    let mut m: HashMap<char, i32> = HashMap::new();
    for c in input {
        m.entry(c).and_modify(|e| *e += 1).or_insert(1);
    }
    m.iter().map(|(k, v)| (*k, *v)).collect()
}

fn checksum(input: String) -> i32 {
    let (twos, threes) = input.split("\n").map(|id| frequencies(id.chars())).fold(
        (0, 0),
        |(mut twos, mut threes), x| {
            twos = if x.iter().any(|(_, v)| *v == 2) {
                twos + 1
            } else {
                twos
            };

            threes = if x.iter().any(|(_, v)| *v == 3) {
                threes + 1
            } else {
                threes
            };

            (twos, threes)
        },
    );
    twos * threes
}

fn main() {
    println!("{}", checksum(read_input()));
}

#[test]
fn test_02() {
    let ids = vec![
        "abcdef", "bababc", "abbcde", "abcccd", "aabcdd", "abcdee", "ababab"
    ];
    assert_eq!(checksum(ids.join("\n")), 12);
}
