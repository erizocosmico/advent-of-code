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

let std_suffix = [17; 31; 73; 47; 23]

let knot_hash_of_string str =
  let lengths = String.fold str ~init:[] ~f:(fun l ch -> List.append l [Caml.int_of_char ch]) in
  knot_hash (List.range 0 256) (List.append lengths std_suffix)

let dense_hash hash =
  hash |> List.groupi ~break:(fun idx _ _ -> Caml.(mod) idx 16 = 0)
  |> List.map ~f:(fun blk -> List.reduce_exn blk ~f:Caml.(lxor) |> Printf.sprintf "%.2x")
  |> List.reduce_exn ~f:(^)

let bin_of_int n =
  if n = 0 then [0]
  else
    let rec f acc n =
      if n = 0 then acc
      else f ((n land 1) :: acc) (n lsr 1)
    in
    f [] n

let binary_hash dense_hash =
  String.fold dense_hash ~init:[] ~f:(fun acc ch ->
      List.append acc (Printf.sprintf "0x%c" ch
                       |> Caml.int_of_string
                       |> bin_of_int))

let key = "jzgqcdpd"

let () =
  List.range 0 128
  |> List.map ~f:(fun x -> knot_hash_of_string (key ^ "-" ^ (Caml.string_of_int x))
                           |> dense_hash
                           |> binary_hash)
  |> List.fold_left ~init:0 ~f:(fun acc row -> acc + List.count row ~f:((=) 1))
  |> Stdio.printf "%d\n"
