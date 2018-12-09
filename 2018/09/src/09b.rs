fn solve(players: usize, marbles: usize) -> usize {
    let mut circle = vec![0];
    let mut current_marble = 0;
    let mut players_score = vec![0usize; players];

    for marble in 1..=marbles {
        if marble % 23 == 0 {
            let to_remove = if current_marble < 7 {
                circle.len() - 7 + current_marble
            } else {
                current_marble - 7
            };
            let removed = circle.remove(to_remove);
            current_marble = to_remove % circle.len();
            players_score[marble % players] += marble + removed;
        } else {
            current_marble = ((current_marble + 1) % circle.len()) + 1;
            circle.insert(current_marble, marble);
        }
    }

    players_score.into_iter().max().unwrap()
}

fn main() {
    println!("{}", solve(416, 71617 * 100));
}

#[test]
fn test_09b() {
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
