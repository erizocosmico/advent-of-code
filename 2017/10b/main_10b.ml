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
      (ls, pos, skip)
    else
      let len = List.hd_exn lengths in
      let remaining = List.tl_exn lengths in
      let stop = if len = 0 then pos else Caml.(mod) (pos + len - 1) ls_size in
      let new_pos = Caml.(mod) (pos + len + skip) ls_size in
      let new_ls = rev_range ls pos stop in
      step new_ls remaining new_pos (skip + 1)
  in
  let rec round ls pos skip r =
    if r = 0 then
      ls
    else
      let (ls, pos, skip) = step ls lengths pos skip in
      round ls pos skip (r - 1)
  in
  round ls 0 0 64 |> Array.to_list

let dense_hash hash = 
  hash |> List.groupi ~break:(fun idx _ _ -> 
      Caml.(mod) idx 16 = 0)
  |> List.map ~f:(fun blk ->
      List.reduce_exn blk ~f:Caml.(lxor)
      |> Printf.sprintf "%.2x")
  |> List.reduce_exn ~f:(^)

let std_suffix = [17; 31; 73; 47; 23]

let () =
  let lengths = In_channel.read_all "10/input.txt" 
                |> String.fold ~init:[] ~f:(fun acc ch -> List.append acc [ch])
                |> List.map ~f:Caml.int_of_char in
  let ls = List.range 0 256 in
  knot_hash ls (List.append lengths std_suffix)
  |> dense_hash
  |> Stdio.print_endline
