#[macro_use]
extern crate lazy_static;
extern crate itertools;
extern crate regex;

use itertools::Itertools;
use regex::Regex;
use std::collections::HashMap;
use std::ops::Range;

#[derive(Ord, PartialEq, PartialOrd, Eq, Debug)]
enum Action {
    StartShift(i32),
    WakeUp,
    FallAsleep,
}

#[derive(Ord, PartialOrd, PartialEq, Eq, Debug)]
struct Log {
    year: i32,
    month: i32,
    day: i32,
    hour: i32,
    minute: i32,
    action: Action,
}

impl Log {
    fn parse(raw_log: &str) -> Log {
        lazy_static! {
            static ref LOG_REGEX: Regex =
                Regex::new(r"^\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] (.+)$").unwrap();
            static ref SHIFT_REGEX: Regex = Regex::new(r"^Guard #(\d+) begins shift$").unwrap();
        }

        let captures = LOG_REGEX.captures(raw_log).unwrap();
        let year = captures.get(1).unwrap().as_str().parse::<i32>().unwrap();
        let month = captures.get(2).unwrap().as_str().parse::<i32>().unwrap();
        let day = captures.get(3).unwrap().as_str().parse::<i32>().unwrap();
        let hour = captures.get(4).unwrap().as_str().parse::<i32>().unwrap();
        let minute = captures.get(5).unwrap().as_str().parse::<i32>().unwrap();
        let action = match captures.get(6).unwrap().as_str() {
            "falls asleep" => Action::FallAsleep,
            "wakes up" => Action::WakeUp,
            a => Action::StartShift(
                SHIFT_REGEX
                    .captures(a)
                    .unwrap()
                    .get(1)
                    .unwrap()
                    .as_str()
                    .parse::<i32>()
                    .unwrap(),
            ),
        };

        Log {
            year,
            month,
            day,
            hour,
            minute,
            action,
        }
    }
}

fn solve(input: String) -> i32 {
    let logs = input.split("\n").map(Log::parse).sorted();

    let mut asleep: HashMap<i32, Vec<Range<i32>>> = HashMap::new();
    let mut id = 0;
    let mut start = 0;
    for log in logs {
        match log.action {
            Action::WakeUp => {
                let range = start..log.minute;
                asleep
                    .entry(id)
                    .and_modify(|e| e.push(range.clone()))
                    .or_insert(vec![range.clone()]);
            }
            Action::FallAsleep => {
                start = log.minute;
            }
            Action::StartShift(guard_id) => {
                id = guard_id;
            }
        }
    }

    asleep
        .iter()
        .map(|(id, ranges)| {
            let minutes: Vec<i32> = ranges.iter().flat_map(|r| r.clone().into_iter()).collect();
            let mut times_minute = HashMap::new();
            for min in &minutes {
                *times_minute.entry(min).or_insert(0) += 1;
            }
            let most_asleep = times_minute
                .iter()
                .max_by(|(_, t1), (_, t2)| t1.cmp(t2))
                .map(|(min, _)| *min)
                .unwrap();
            (*id, minutes.len() as i32, *most_asleep)
        })
        .max_by(|(_, m1, _), (_, m2, _)| m1.cmp(m2))
        .map(|(id, _, most_asleep)| id * most_asleep)
        .unwrap()
}

fn main() {
    let input = include_str!("input.txt").into();
    println!("{}", solve(input));
}

#[test]
fn test_04() {
    let input = vec![
        "[1518-11-01 00:00] Guard #10 begins shift",
        "[1518-11-01 00:05] falls asleep",
        "[1518-11-01 00:25] wakes up",
        "[1518-11-01 00:30] falls asleep",
        "[1518-11-01 00:55] wakes up",
        "[1518-11-01 23:58] Guard #99 begins shift",
        "[1518-11-02 00:40] falls asleep",
        "[1518-11-02 00:50] wakes up",
        "[1518-11-03 00:05] Guard #10 begins shift",
        "[1518-11-03 00:24] falls asleep",
        "[1518-11-03 00:29] wakes up",
        "[1518-11-04 00:02] Guard #99 begins shift",
        "[1518-11-04 00:36] falls asleep",
        "[1518-11-04 00:46] wakes up",
        "[1518-11-05 00:03] Guard #99 begins shift",
        "[1518-11-05 00:45] falls asleep",
        "[1518-11-05 00:55] wakes up",
    ];

    let result = solve(input.join("\n"));
    assert_eq!(result, 240);
}
