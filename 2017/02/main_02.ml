open Base
open Stdio

let transform_line line =
  String.split line '\t' |> List.map ~f:Caml.int_of_string

let read_input name =
  In_channel.read_lines name |> List.map ~f:transform_line

let find_minmax nums =
  let find (min, max) n =
    let lowest = match min with
    | Some(num) -> if n < num then n else num
    | None -> n in
    let highest = match max with
    | Some(num) -> if n > num then n else num
    | None -> n in
    (Some(lowest), Some(highest))
  in
  let (min, max) = List.fold_left nums ~init:(None, None) ~f:find in
  (Option.value_exn min, Option.value_exn max)

let linediff line =
  let (min, max) = find_minmax line in
  max - min

let checksum input =
  List.map input linediff |> List.reduce_exn ~f:(+)

let () =
  let input = read_input "02/input.txt" in
  Stdio.printf "%d\n" (checksum input)
