#[macro_use]
extern crate lazy_static;
extern crate regex;

use regex::Regex;
use std::collections::HashMap;
use std::collections::HashSet;
use std::iter::FromIterator;

fn parse(str: &str) -> (char, char) {
    lazy_static! {
        static ref RE: Regex =
            Regex::new(r"^Step ([A-Z]) must be finished before step ([A-Z])").unwrap();
    }

    let c = RE.captures(str).unwrap();
    (
        c.get(1).unwrap().as_str().chars().next().unwrap(),
        c.get(2).unwrap().as_str().chars().next().unwrap(),
    )
}

fn ready_steps(steps: &HashMap<char, Vec<char>>) -> Vec<char> {
    let s: HashSet<_> = steps.keys().collect();
    let dependants: HashSet<_> = steps.values().flat_map(|x| x).collect();
    let mut ready: Vec<char> = s.difference(&dependants).into_iter().map(|x| **x).collect();
    ready.sort();
    ready
}

fn is_ready(steps: &HashMap<char, Vec<char>>, step: char) -> bool {
    !steps.values().flat_map(|x| x).any(|&x| x == step)
}

fn step_order(input: String) -> String {
    let mut steps = HashMap::new();
    input
        .split("\n")
        .map(parse)
        .for_each(|(parent, child)| steps.entry(parent).or_insert(Vec::new()).push(child));

    let mut ready = ready_steps(&steps);
    let mut order = Vec::new();
    while !ready.is_empty() {
        let step = ready.remove(0);
        order.push(step);

        if let Some(dependants) = (&mut steps).remove(&step) {
            ready.append(&mut dependants
                .into_iter()
                .filter(|&x| is_ready(&steps, x))
                .collect::<Vec<_>>());
            ready.sort();
            ready.dedup();
        }
    }

    String::from_iter(order)
}

fn main() {
    println!("{}", step_order(include_str!("input.txt").into()));
}

#[test]
fn test_07() {
    let input = vec![
        "Step C must be finished before step A can begin.",
        "Step C must be finished before step F can begin.",
        "Step A must be finished before step B can begin.",
        "Step A must be finished before step D can begin.",
        "Step B must be finished before step E can begin.",
        "Step D must be finished before step E can begin.",
        "Step F must be finished before step E can begin.",
    ];
    let result = step_order(input.join("\n").into());
    assert_eq!(result, "CABDFE".to_string());
}
