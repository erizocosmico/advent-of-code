#[derive(Clone, Copy)]
struct Node {
    prev: usize,
    next: usize,
    value: usize,
}

struct Circle {
    nodes: Vec<Node>,
    cursor: Option<usize>,
}

impl Circle {
    fn new(capacity: usize) -> Circle {
        Circle {
            nodes: Vec::with_capacity(capacity),
            cursor: None,
        }
    }

    fn rotate(&mut self, delta: isize) -> &mut Self {
        if delta > 0 {
            self.cursor = self.cursor.map(|c| {
                let mut cur = c;
                for _ in 0..delta {
                    cur = self.nodes[cur].next;
                }
                cur
            })
        } else if delta < 0 {
            self.cursor = self.cursor.map(|c| {
                let mut cur = c;
                for _ in delta..0 {
                    cur = self.nodes[cur].prev;
                }
                cur
            })
        }
        self
    }

    fn remove(&mut self) -> Option<usize> {
        let val = self.cursor.map(|c| self.nodes[c].value);
        self.cursor = self.cursor.and_then(|c| {
            let node = self.nodes[c];
            if node.next == c {
                None
            } else {
                self.nodes[node.prev].next = node.next;
                self.nodes[node.next].prev = node.prev;
                Some(node.next)
            }
        });
        val
    }

    fn insert(&mut self, value: usize) {
        let (prev, next) = self.cursor
            .map(|c| (c, self.nodes[c].next))
            .unwrap_or((0, 0));
        let curr = self.nodes.len();

        self.nodes.push(Node { prev, next, value });

        self.cursor = Some(curr);
        self.nodes[prev].next = curr;
        self.nodes[next].prev = curr;
    }
}

fn solve(players: usize, marbles: usize) -> usize {
    let mut circle = Circle::new(marbles + 1);
    let mut players_score = vec![0usize; players];
    circle.insert(0);

    for marble in 1..=marbles {
        if marble % 23 == 0 {
            let removed = circle.rotate(-7).remove().unwrap_or(0);
            players_score[marble % players] += marble + removed;
        } else {
            circle.rotate(1).insert(marble);
        }
    }

    players_score.into_iter().max().unwrap()
}

fn main() {
    println!("{}", solve(416, 71617));
}

#[test]
fn test_09() {
    let test_cases = vec![
        (9, 25, 32),
        (10, 1618, 8317),
        (13, 7999, 146373),
        (17, 1104, 2764),
        (21, 6111, 54718),
        (30, 5807, 37305),
    ];

    for tc in test_cases {
        assert_eq!(tc.2, solve(tc.0, tc.1));
    }
}
