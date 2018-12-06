use std::iter::FromIterator;

fn scan_polymer(input: String) -> String {
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

    String::from_iter(units)
}

fn reacts(a: char, b: char) -> bool {
    a != b && a.to_lowercase().to_string() == b.to_lowercase().to_string()
}

fn main() {
    let input = include_str!("input.txt").into();
    println!("{}", scan_polymer(input).len());
}

#[test]
fn test_05() {
    let input = "dabAcCaCBAcCcaDA".into();

    let result = scan_polymer(input);
    assert_eq!(result.len(), 10);
}
