use std::collections::HashSet;

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
    let input = include_str!("input.txt").into();
    println!("{}", first_frequency_reached_twice(input));
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
