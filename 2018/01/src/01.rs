fn calculate_frequency(input: String) -> i32 {
    input
        .split("\n")
        .map(|x| x.parse::<i32>().unwrap())
        .fold(0, |acc, x| acc + x)
}

fn main() {
    let input = include_str!("input.txt").into();
    println!("{}", calculate_frequency(input));
}

#[test]
fn test_01() {
    assert_eq!(calculate_frequency("+1\n+1\n+1".into()), 3);
    assert_eq!(calculate_frequency("+1\n+1\n-2".into()), 0);
    assert_eq!(calculate_frequency("-1\n-2\n-3".into()), -6);
}
