fn solve(num_recipes: usize) -> String {
    let mut recipes: Vec<usize> = vec![3, 7];
    let mut current_recipes: Vec<usize> = vec![0, 1];
    while recipes.len() < num_recipes + 10 {
        let sum = (&current_recipes)
            .into_iter()
            .map(|i| recipes[*i])
            .sum::<usize>();
        recipes.append(&mut sum.to_string()
            .chars()
            .map(|d| d.to_digit(10).unwrap() as usize)
            .collect());

        current_recipes = current_recipes
            .into_iter()
            .map(|i| (i + recipes[i] + 1) % recipes.len())
            .collect();
    }

    recipes[num_recipes..(num_recipes + 10)]
        .into_iter()
        .map(|n| ((n + 48) as u8) as char)
        .collect::<String>()
}

fn main() {
    println!("{}", solve(84601));
}

#[test]
fn test_14() {
    assert_eq!(solve(9), "5158916779".to_owned());
    assert_eq!(solve(5), "0124515891".to_owned());
    assert_eq!(solve(18), "9251071085".to_owned());
    assert_eq!(solve(2018), "5941429882".to_owned());
}
