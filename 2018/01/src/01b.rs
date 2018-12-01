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

fn first_frequency_reached_twice(input: String) -> i32 {
    let changes = input.split("\n").map(|x| x.parse::<i32>().unwrap()).cycle();
    let mut frequency_history = HashSet::new();
    frequency_history.insert(0);

    let mut freq: i32 = 0;
    for change in changes {
        freq += change;
        if frequency_history.contains(&freq) {
            break;
        }

        frequency_history.insert(freq);
    }

    freq
}

fn main() {
    println!("{}", first_frequency_reached_twice(read_input()));
}

#[test]
fn test_01b() {
    assert_eq!(first_frequency_reached_twice("+1\n-1".into()), 0);

    assert_eq!(
        first_frequency_reached_twice("+3\n+3\n+4\n-2\n-4".into()),
        10
    );

    assert_eq!(
        first_frequency_reached_twice("-6\n+3\n+8\n+5\n-6".into()),
        5
    );

    assert_eq!(
        first_frequency_reached_twice("+7\n+7\n-2\n-7\n-4".into()),
        14
    );
}
