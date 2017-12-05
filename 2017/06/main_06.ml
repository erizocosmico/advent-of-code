open Base
open Stdio

let max_value_index l =
  let (max_idx, _) = List.foldi l ~init:(0, 0) ~f:(fun idx (max_idx, max_val) value ->
      if value > max_val then (idx, value) else (max_idx, max_val)) in
  max_idx

let set_bank banks idx n = List.mapi banks (fun i v -> if i = idx then n else v)

let incr_bank banks idx = List.mapi banks (fun i v -> if i = idx then v + 1 else v)

let redistribute_banks banks =
  let num_banks = List.length banks in
  let max_idx = max_value_index banks in
  let blocks = List.nth_exn banks max_idx in
  let rec redistribute banks remaining_blocks prev_idx =
    if remaining_blocks > 0 then
      let idx = if prev_idx + 1 >= num_banks then 0 else prev_idx + 1 in
      redistribute (incr_bank banks idx) (remaining_blocks - 1) idx
    else
      banks
  in
  redistribute (set_bank banks max_idx 0) blocks max_idx

let string_of_banks banks = 
  List.map banks ~f:Caml.string_of_int |> String.concat ~sep:","

let redistributions_until_loop banks =
  let rec unique_states banks seen_states =
    let state = string_of_banks banks in
    if Set.mem seen_states state then
      seen_states
    else
      unique_states (redistribute_banks banks) (Set.add seen_states state)
  in
  unique_states banks (Set.empty (module String)) |> Set.length

let () =
  let banks = In_channel.read_all "06/input.txt" 
              |> String.split ~on:'\t' 
              |> List.map ~f:Caml.int_of_string in
  redistributions_until_loop banks
  |> Stdio.printf "%d\n"
