#[macro_use]
extern crate lazy_static;
extern crate regex;

use regex::Regex;
use std::cmp::min;
use std::collections::HashMap;
use std::collections::HashSet;

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

fn completion_time(input: String, max_workers: u32, task_cost: u32) -> u32 {
    let mut steps = HashMap::new();
    input
        .split("\n")
        .map(parse)
        .for_each(|(parent, child)| steps.entry(parent).or_insert(Vec::new()).push(child));

    let mut ready = ready_steps(&steps);
    let mut time = 0;
    let mut workers = max_workers;
    let mut pending = HashMap::new();
    while !ready.is_empty() || !pending.is_empty() {
        for _ in 0..min(workers, ready.len() as u32) {
            let step = ready.remove(0);
            *pending.entry(step).or_insert(0) = task_cost + step as u32 - 64;
            workers -= 1;
        }

        let min_remaining = *pending.values().min().unwrap();
        time += min_remaining;

        let pending_steps: Vec<_> = pending.keys().map(|x| *x).collect();
        for k in pending_steps {
            pending.entry(k).and_modify(|x| *x -= min_remaining);

            if *pending.get(&k).unwrap() == 0 {
                pending.remove(&k);

                if let Some(dependants) = (&mut steps).remove(&k) {
                    ready.append(&mut dependants
                        .into_iter()
                        .filter(|&x| is_ready(&steps, x))
                        .collect::<Vec<_>>());
                    ready.sort();
                    ready.dedup();
                }

                workers += 1;
            }
        }
    }

    time
}

fn main() {
    println!(
        "{}",
        completion_time(include_str!("input.txt").into(), 5, 60)
    );
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
    let result = completion_time(input.join("\n").into(), 2, 0);
    assert_eq!(result, 15);
}
