open Base
open Stdio

type instruction = {
  register : string;
  op : int -> int;
  cond_register : string;
  cond_op : int -> int -> bool;
  cond_value : int;
}

exception Invalid_op of string

let op_of_string = function
  | "==" -> (=)
  | "!=" -> (<>)
  | "<" -> (<)
  | ">" -> (>)
  | ">=" -> (>=)
  | "<=" -> (<=)
  | op -> raise (Invalid_op op)

let incr value ~by = value + by
let decr value ~by = value - by

let instruction_of_string s =
  let parts = String.split s ' ' |> Array.of_list in
  let value = Array.nget parts 2 |> Caml.int_of_string in
  { register = Array.nget parts 0;
    op = if String.equal (Array.nget parts 1) "inc" then incr ~by:value else decr ~by:value;
    cond_register = Array.nget parts 4;
    cond_value = Array.nget parts 6 |> Caml.int_of_string;
    cond_op = Array.nget parts 5 |> op_of_string
  }

let find_register registers register = Map.find registers register |> Option.value ~default:0

let exec instructions =
  let rec _exec instructions registers values =
    if List.is_empty instructions then
      (registers, values)
    else
      let inst = List.hd_exn instructions in
      let remaining = List.tl_exn instructions in
      let register = find_register registers inst.register in
      let cond_register = find_register registers inst.cond_register in
      if inst.cond_op cond_register inst.cond_value then
        let new_val = inst.op register in
        _exec remaining (Map.add registers inst.register new_val) (Set.add values new_val)
      else
        _exec remaining registers values
  in
  _exec instructions (Map.empty (module String)) (Set.empty (module Int))

let () =
  let instructions = In_channel.read_lines "08/input.txt"
                     |> List.map ~f:instruction_of_string in
  let (_, values) = exec instructions in
  let max_val = Set.max_elt_exn values in
  Stdio.printf "%d\n" max_val