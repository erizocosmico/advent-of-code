open Base
open Stdio

let rev_range ls start stop =
  let ls_size = Array.length ls in
  let opposed idx = Array.nget ls (Caml.(mod) (stop - (idx - start)) ls_size) in
  Array.mapi ls ~f:(fun idx n ->
      if (start <= stop && idx >= start && idx <= stop) || (start > stop && (idx <= stop || idx >= start)) then
        opposed idx
      else n)

let knot_hash ls lengths =
  let ls = Array.of_list ls in
  let ls_size = Array.length ls in
  let rec step ls lengths pos skip =
    if List.is_empty lengths then
      ls
    else
      let len = List.hd_exn lengths in
      let remaining = List.tl_exn lengths in
      let stop = if len = 0 then pos else Caml.(mod) (pos + len - 1) ls_size in
      let new_pos = Caml.(mod) (pos + len + skip) ls_size in
      let new_ls = rev_range ls pos stop in
      step new_ls remaining new_pos (skip + 1)
  in
  step ls lengths 0 0

let () =
  let lengths = In_channel.read_all "10/input.txt" 
                |> String.split ~on:',' 
                |> List.map ~f:Caml.int_of_string in
  let ls = List.range 0 256 in
  let hash = knot_hash ls lengths in
  (Array.nget hash 0 * Array.nget hash 1)
  |> Stdio.printf "%d\n"
