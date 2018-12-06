fn diff(a: &str, b: &str) -> i32 {
    let mut diff = 0;
    for (a, b) in a.chars().zip(b.chars()) {
        if a != b {
            diff += 1;
        }
    }
    diff
}

fn matching_chars(a: &str, b: &str) -> String {
    a.chars()
        .zip(b.chars())
        .filter(|(a, b)| a == b)
        .map(|(a, _)| a)
        .collect::<String>()
}

fn solve(input: String) -> String {
    let ids: &Vec<&str> = &input.split("\n").collect();
    ids.iter()
        .enumerate()
        .filter_map(|(idx, id)| {
            ids.iter()
                .skip(idx + 1)
                .find(|x| diff(x, id) == 1)
                .map(|x| matching_chars(x, id))
        })
        .next()
        .unwrap()
}

fn main() {
    let input = include_str!("input.txt").into();
    println!("{}", solve(input));
}

#[test]
fn test_02b() {
    let ids = vec![
        "abcde", "fghij", "klmno", "pqrst", "fguij", "axcye", "wvxyz"
    ];
    assert_eq!(solve(ids.join("\n")), "fgij");
}
