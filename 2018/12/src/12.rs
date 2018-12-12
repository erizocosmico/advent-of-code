use std::collections::HashMap;

fn evolve(prev_state: String, rules: &HashMap<String, char>) -> String {
    let state = "....".to_owned() + &prev_state + "....";

    let mut result = String::new();
    for i in 2..(state.len() - 2) {
        result.push(*rules.get(state[(i - 2)..(i + 3)].into()).unwrap_or(&'.'));
    }

    result
}

fn solve(initial_state: String, raw_rules: String) -> isize {
    let rules: HashMap<String, char> = raw_rules
        .split("\n")
        .map(|x| {
            let pattern: String = x[0..5].into();
            let replacement: char = x.chars().next_back().unwrap();
            (pattern, replacement)
        })
        .collect();

    let mut state = initial_state;
    for _ in 0..20 {
        state = evolve(state, &rules);
    }

    state
        .chars()
        .enumerate()
        .filter_map(|(i, x)| match x {
            '#' => Some(i as isize - 40),
            _ => None,
        })
        .sum()
}

fn main() {
    let initial_state = ".##..##..####..#.#.#.###....#...#..#.#.#..#...#....##.#.#.#.#.#..######.##....##.###....##..#.####.#";
    println!(
        "{}",
        solve(initial_state.into(), include_str!("input.txt").into())
    );
}

#[test]
fn test_12() {
    let initial_state = "#..#.#..##......###...###";
    let rules = vec![
        "...## => #",
        "..#.. => #",
        ".#... => #",
        ".#.#. => #",
        ".#.## => #",
        ".##.. => #",
        ".#### => #",
        "#.#.# => #",
        "#.### => #",
        "##.#. => #",
        "##.## => #",
        "###.. => #",
        "###.# => #",
        "####. => #",
    ];

    let result = solve(initial_state.into(), rules.join("\n").into());
    assert_eq!(result, 325);
}
