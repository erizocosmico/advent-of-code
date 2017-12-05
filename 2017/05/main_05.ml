open Base
open Stdio

let jumps_until_exit offset_list =
  let offsets = Array.of_list offset_list in
  let num_offsets = Array.length offsets in
  let rec next_jump i pos =
    if pos >= num_offsets || pos < 0 then
      i
    else
      (let offset = Array.get offsets pos in
       let new_pos = pos + offset in
       Array.set offsets pos (offset + 1);
       next_jump (i + 1) new_pos)
  in
  next_jump 0 0

let () =
  let offsets = In_channel.read_lines "05/input.txt"
                |> List.map ~f:(Caml.int_of_string)
  in
  Stdio.printf "%d\n" (jumps_until_exit offsets)