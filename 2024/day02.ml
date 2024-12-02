open Stdio
open Base

let parse_report line = String.split line ~on:' ' |> List.map ~f:Int.of_string

let is_safe report =
  let rec f curr rest dir =
    match rest with
    | [] -> true
    | hd :: tl -> (
        let curr_dir = Int.descending curr hd in
        let change = Int.abs (curr - hd) in
        match dir with
        | Some d when d <> curr_dir -> false
        | _ ->
            if Int.between change ~low:1 ~high:3 then f hd tl (Some curr_dir)
            else false)
  in
  f (List.hd_exn report) (List.tl_exn report) None

let is_safe2 report =
  if is_safe report then true
  else
    let rec f prev rest =
      match rest with
      | [] -> false
      | _ :: [] -> is_safe prev
      | hd :: tl ->
          if is_safe (List.append prev tl) then true
          else f (List.append prev [ hd ]) tl
    in
    f [] report

let () =
  let reports =
    In_channel.read_all "inputs/02.txt"
    |> String.rstrip |> String.split_lines |> List.map ~f:parse_report
  in
  let part1 = List.count reports ~f:is_safe in
  let part2 = List.count reports ~f:is_safe2 in
  Stdio.printf "Part one: %d\nPart two: %d\n" part1 part2
