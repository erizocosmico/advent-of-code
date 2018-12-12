use std::collections::HashMap;

fn evolve(prev_state: String, rules: &HashMap<String, char>) -> String {
    let state = "....".to_owned() + &prev_state + "....";

    let mut result = String::new();
    for i in 2..(state.len() - 2) {
        result.push(*rules.get(state[(i - 2)..(i + 3)].into()).unwrap_or(&'.'));
    }

    result
}

fn sum(state: &String, gens: usize) -> isize {
    state
        .chars()
        .enumerate()
        .filter_map(|(i, x)| match x {
            '#' => Some(i as isize - (2 * gens as isize)),
            _ => None,
        })
        .sum()
}

fn converges(diffs: &Vec<isize>) -> bool {
    // We can assume it has converged if the last 100 diffs are the same
    let len = diffs.len();
    let last = diffs[len - 1];
    for i in 1..=100 {
        if diffs[len - i - 1] != last {
            return false;
        }
    }

    true
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
    let mut last_sum = sum(&state, 0);
    let mut diffs = vec![];
    let gens: usize = 50000000000;

    for i in 0..gens {
        state = evolve(state, &rules);

        let sum = sum(&state, i + 1);
        let diff = sum - last_sum;
        last_sum = sum;
        diffs.push(diff);

        if i > 100 && converges(&diffs) {
            return sum + (gens - (i + 1)) as isize * diff;
        }
    }

    panic!("it did not converge")
}

fn main() {
    let initial_state = ".##..##..####..#.#.#.###....#...#..#.#.#..#...#....##.#.#.#.#.#..######.##....##.###....##..#.####.#";
    println!(
        "{}",
        solve(initial_state.into(), include_str!("input.txt").into())
    );
}
