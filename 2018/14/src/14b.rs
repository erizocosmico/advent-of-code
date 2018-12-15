fn solve(needle: &str) -> usize {
    let mut recipes: Vec<usize> = vec![3, 7];
    let mut current_recipes: Vec<usize> = vec![0, 1];
    loop {
        let new_recipes: Vec<_> = (&current_recipes)
            .iter()
            .map(|i| recipes[*i])
            .sum::<usize>()
            .to_string()
            .chars()
            .map(|d| d.to_digit(10).unwrap() as usize)
            .collect();

        for r in new_recipes {
            recipes.push(r);

            if recipes.len() >= needle.len() {
                let mut x = String::new();
                recipes[recipes.len() - needle.len()..]
                    .iter()
                    .for_each(|c| {
                        x.push((*c as u8 + 48) as char);
                    });
                if x == needle {
                    return recipes.len() - needle.len();
                }
            }
        }

        current_recipes = current_recipes
            .into_iter()
            .map(|i| (i + recipes[i] + 1) % recipes.len())
            .collect();
    }
}

fn main() {
    println!("{}", solve("084601"));
}

#[test]
fn test_14b() {
    assert_eq!(solve("51589"), 9);
    assert_eq!(solve("01245"), 5);
    assert_eq!(solve("92510"), 18);
    assert_eq!(solve("59414"), 2018);
}
