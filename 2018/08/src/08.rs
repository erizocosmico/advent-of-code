struct Node {
    children: Vec<Node>,
    metadata: Vec<u32>,
}

impl Node {
    fn check(&self) -> u32 {
        (&self.metadata).into_iter().sum::<u32>()
            + (&self.children).into_iter().map(|x| x.check()).sum::<u32>()
    }
}

fn read_node(iter: &mut Iterator<Item = u32>) -> Node {
    let children_len = iter.next().unwrap();
    let metadata_len = iter.next().unwrap();

    let mut children = Vec::new();
    for _ in 0..children_len {
        children.push(read_node(iter));
    }

    let mut metadata = Vec::new();
    for _ in 0..metadata_len {
        metadata.push(iter.next().unwrap());
    }

    Node { children, metadata }
}

fn check(input: String) -> u32 {
    let node = read_node(&mut input.split(" ").map(|x| x.parse::<u32>().unwrap()));
    node.check()
}

fn main() {
    println!("{}", check(include_str!("input.txt").into()));
}

#[test]
fn test_08() {
    let input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2";
    let result = check(input.into());
    assert_eq!(138, result);
}
