open Stdio
open Base

exception Invalid_opcode of int

let int_of_char ch = (Char.to_int ch) - 48

let run_program codes idx inputs = let i = ref idx in
  let output = ref None in
  let stop = ref false in
  let inputs = ref inputs in
  while not !stop do
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
      let input = List.hd_exn !inputs in
      if List.length !inputs > 1 then
        inputs := List.drop !inputs 1;
      Array.set codes (Array.get codes (!i + 1)) input;
      i := !i + 2
    | 4 ->
      let v = param 0 in
      output := Some v;
      stop := true;
      i := !i + 2
    | 5 ->
      if param 0 <> 0 then
        i := param 1
      else
        i := !i + 3
    | 6 ->
      if param 0 = 0 then
        i := param 1
      else
        i := !i + 3
    | 7 ->
      let v = if param 0 < param 1 then 1 else 0 in
      Array.set codes (Array.get codes (!i + 3)) v;
      i := !i + 4
    | 8 ->
      let v = if param 0 = param 1 then 1 else 0 in
      Array.set codes (Array.get codes (!i + 3)) v;
      i := !i + 4
    | 99 -> stop := true
    | opcode ->
      raise (Invalid_opcode opcode)
  done;
  (!i, !output)

let run_amplifiers codes phases =
  let phases = ref phases in
  let prev_output = ref 0 in
  let stop = ref false in
  let amplifier_codes = List.range 0 5
                        |> List.map ~f:(fun _ -> Array.copy codes)
                        |> Array.of_list in
  let amplifier_ptrs = Array.create ~len:5 0 in
  let amplifier = ref 0 in
  while not !stop do
    let inputs = match !phases with
      | [] -> [!prev_output]
      | xs -> 
        let hd = List.hd_exn xs in
        phases := List.drop xs 1;
        [hd; !prev_output] 
    in
    let ptr = Array.get amplifier_ptrs !amplifier in
    let codes = Array.get amplifier_codes !amplifier in
    let (idx, output) = run_program codes ptr inputs in
    Array.set amplifier_ptrs !amplifier idx;
    match output with
    | None-> stop := true
    | Some x -> prev_output := x;
      if !amplifier = 4 then
        amplifier := 0
      else
        amplifier := !amplifier + 1
  done;
  !prev_output

(* Permutations functions from https://gist.github.com/Bamco/6151962 *)
let rec interleave x lst = 
  match lst with
  | [] -> [[x]]
  | hd::tl -> (x::lst) :: (List.map ~f:(fun y -> hd::y) (interleave x tl))

let rec permutations lst = 
  match lst with
  | hd::tl -> List.concat (List.map ~f:(interleave hd) (permutations tl))
  | _ -> [lst]

let () =
  let codes =
    In_channel.read_all "input.txt" 
    |> String.rstrip 
    |> String.split ~on:','
    |> List.map ~f:Int.of_string
    |> Array.of_list
  in
  List.range 5 10 |> permutations
  |> List.map ~f:(run_amplifiers codes)
  |> List.max_elt ~compare:Int.compare
  |> Option.value ~default:0
  |> Stdio.printf "%d\n"
