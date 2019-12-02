open Stdio
open Base

exception Invalid_opcode of int
exception Invalid_result of int

let compute memory noun verb =
  let mem = Array.copy memory in
  Array.set mem 1 noun;
  Array.set mem 2 verb;
  let i = ref 0 in
  while !i < Array.length mem do
    match Array.get mem !i with
    | 1 | 2 as opcode ->
      let a = Array.get mem (Array.get mem (!i + 1)) in
      let b = Array.get mem (Array.get mem (!i + 2)) in
      let op = if opcode = 1 then ( + ) else ( * ) in
      Array.set mem (Array.get mem (!i + 3)) (op a b);
      i := !i + 4
    | 99 -> i := Array.length mem
    | opcode ->
      raise (Invalid_opcode opcode)
  done;
  Array.get mem 0

let () =
  let memory =
    In_channel.read_all "input.txt" 
    |> String.rstrip 
    |> String.split ~on:','
    |> List.map ~f:Int.of_string
    |> Array.of_list
  in
  let initial = compute memory 0 0 in
  let noun_incr = (compute memory 1 0) - initial in
  let verb_incr = (compute memory 0 1) - initial in
  let target = 19690720 in
  let noun = (target - initial) / noun_incr in
  let verb = (target - (noun * noun_incr + initial)) / verb_incr in
  let result = compute memory noun verb in
  if result = target then
    Stdio.printf "%d\n" (noun * 100 + verb)
  else
    raise (Invalid_result result)