use std::io::prelude::*;
use std::fs::File;

struct Registers {
    a: i32,
    b: i32,
    c: i32,
    d: i32
}

impl Registers {
    fn new() -> Registers {
        Registers{a: 0, b: 0, c: 0, d: 0}
    }

    fn get(&self, name: &str) -> i32 {
        match name {
            "a" => self.a,
            "b" => self.b,
            "c" => self.c,
            "d" => self.d,
            _ => panic!("invalid register {}!", name),
        }
    }

    fn inc(&mut self, name: &str) {
        let curr_val = self.get(name);
        self.set(name, curr_val + 1);
    }

    fn dec(&mut self, name: &str) {
        let curr_val = self.get(name);
        self.set(name, curr_val - 1);
    }

    fn set(&mut self, name: &str, val: i32) {
        match name {
            "a" => self.a = val,
            "b" => self.b = val,
            "c" => self.c = val,
            "d" => self.d = val,
            _ => panic!("invalid register {}!", name),
        }
    }
}

fn main() {
    let mut f = File::open("data.txt").expect("unable to open file");
    let mut data = String::new();
    f.read_to_string(&mut data).expect("unable to read file");

    let mut instructions: Vec<&str>  = data.split("\n").collect();
    instructions.pop();
    let mut regs = Registers::new();
    let mut current_ins: i32 = 0;
    loop {
        if current_ins < 0 || current_ins as usize >= instructions.len() {
            break;
        }

        let (op, args_str) = instructions[current_ins as usize].split_at(3);
        let args: Vec<&str> = args_str.trim().split(" ").collect();
        match op {
            "cpy" => match args[0].parse::<i32>() {
                Ok(n) => regs.set(args[1], n),
                Err(_) => {
                    let val = regs.get(args[0]);
                    regs.set(args[1], val);
                },
            },
            "inc" => regs.inc(args[0]),
            "dec" => regs.dec(args[0]),
            "jnz" => if match args[0].parse::<i32>() {
                Ok(n) => n != 0,
                Err(_) => regs.get(args[0]) != 0,
            } {
                current_ins += args[1].parse::<i32>().unwrap();
                continue;
            },
            _ => (),
        }
        current_ins += 1;
    }
    println!("{}", regs.a);
}
