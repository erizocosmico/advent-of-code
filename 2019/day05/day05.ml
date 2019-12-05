open Stdio
open Base

exception Invalid_opcode of int

let int_of_char ch = (Char.to_int ch) - 48

let run codes input = let i = ref 0 in
  let output = ref [] in
  while !i < Array.length codes do
    let code = Array.get codes !i |> Int.to_string in
    let len = String.length code in
    let opcode = Int.of_string (
        if len >= 2 then
          String.drop_prefix code ((String.length code) - 2) 
        else code
      )
    in
    let param_modes = String.drop_suffix code 2 
                      |> String.to_list 
                      |> Array.of_list_rev 
                      |> Array.map ~f:int_of_char in
    let param idx =
      let p = Array.get codes (!i + idx + 1) in
      let mode = if Array.length param_modes > idx 
        then Array.get param_modes idx
        else 0 
      in
      if mode = 0 then Array.get codes p else p
    in
    match opcode with
    | 1 | 2 ->
      let a = param 0 in
      let b = param 1 in
      let dst = Array.get codes (!i + 3) in
      let op = if opcode = 1 then ( + ) else ( * ) in
      Array.set codes dst (op a b);
      i := !i + 4
    | 3 ->
      Array.set codes (Array.get codes (!i + 1)) input;
      i := !i + 2
    | 4 ->
      let v = param 0 in
      output := v :: !output;
      i := !i + 2
    | 99 -> i := Array.length codes
    | opcode ->
      raise (Invalid_opcode opcode)
  done;
  !output

let () =
  let codes =
    In_channel.read_all "input.txt" 
    |> String.rstrip 
    |> String.split ~on:','
    |> List.map ~f:Int.of_string
    |> Array.of_list
  in
  run codes 1
  |> List.rev_map ~f:Int.to_string
  |> String.concat ~sep:","
  |> Stdio.print_endline;;