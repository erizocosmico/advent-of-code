open Base
open Stdio

type op = Send of int | Recv | Done

type program = { 
  registers: (Char.t, int, Char.comparator_witness) Map.t;
  pos: int;
  channel: int list;
  sent: int;
}

let new_program n = {
  registers = Map.singleton (module Char) 'p' n;
  pos = 0;
  channel = [];
  sent = 0;
}

let incr_pos n program = {program with pos = program.pos + n}

let set_register reg value program = 
  { program with registers = Map.add program.registers reg value }

let value_of program x = let fc = String.get x 0 in
  if Char.is_alpha fc then
    Map.find program.registers fc |> Option.value ~default:0
  else
    Caml.int_of_string x

let send n program = { program with channel = List.append program.channel [n]}

let exec instructions =
  let size = Array.length instructions in
  let rec exec_program program =
    if program.pos >= size then (Done, program)
    else
      let inst = Array.nget instructions program.pos in
      let parts = String.split inst ~on:' ' |> Array.of_list in
      let reg = String.get parts.(1) 0 in
      let x = value_of program parts.(1) in
      match parts.(0) with
      | "snd" -> (Send x, incr_pos 1 {program with sent = program.sent + 1})
      | "set" -> 
        let program = set_register reg (value_of program parts.(2)) program in
        exec_program (incr_pos 1 program)
      | "add" ->
        let program = set_register reg (x + value_of program parts.(2)) program in
        exec_program (incr_pos 1 program)
      | "mul" ->
        let program = set_register reg (x * value_of program parts.(2)) program in
        exec_program (incr_pos 1 program)
      | "mod" ->
        let program = set_register reg (Caml.(mod) x (value_of program parts.(2))) program in
        exec_program (incr_pos 1 program)
      | "rcv" -> if List.is_empty program.channel then
          (Recv, program)
        else
          let hd = List.hd_exn program.channel in
          let tail = List.tl_exn program.channel in
          let program = set_register reg hd {program with channel = tail} in
          exec_program (incr_pos 1 program)
      | "jgz" -> 
        let pos_delta = if x > 0 then value_of program parts.(2) else 1 in
        exec_program (incr_pos pos_delta program)
      | _ -> exec_program (incr_pos 1 program)
  in
  let rec aux (p0, p1) =
    let (op0, p0) = exec_program p0 in
    let (op1, p1) = exec_program p1 in
    match (op0, op1) with
    | (Done, Done) | (Recv, Recv) -> p1.sent
    | (Send a, Send b) -> aux (send b p0, send a p1)
    | (Send a, _) -> aux (p0, send a p1)
    | (_, Send b) -> aux (send b p0, p1)
    | _ -> 0
  in
  aux (new_program 0, new_program 1)

let () =
  In_channel.read_lines "18/input.txt"
  |> Array.of_list
  |> exec
  |> Stdio.printf "%d\n"
