open Stdio
open Base

exception Invalid_opcode of int

let run codes = let i = ref 0 in
  while !i < Array.length codes do
    match Array.get codes !i with
    | 1 | 2 as opcode ->
      let a = Array.get codes (Array.get codes (!i + 1)) in
      let b = Array.get codes (Array.get codes (!i + 2)) in
      let op = if opcode = 1 then ( + ) else ( * ) in
      Array.set codes (Array.get codes (!i + 3)) (op a b);
      i := !i + 4
    | 99 -> i := Array.length codes
    | opcode ->
      raise (Invalid_opcode opcode)
  done;;

let () =
  let codes =
    In_channel.read_all "input.txt" 
    |> String.rstrip 
    |> String.split ~on:','
    |> List.map ~f:Int.of_string
    |> Array.of_list
  in
  Array.set codes 1 12;
  Array.set codes 2 2;
  run codes;
  Stdio.printf "%d\n" (Array.get codes 0)