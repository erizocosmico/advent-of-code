open Stdio
open Base

let parse_pair line =
  let pair =
    line |> String.split ~on:' '
    |> List.filter ~f:(fun s -> not (String.is_empty s))
    |> List.map ~f:Int.of_string
  in
  (List.hd_exn pair, List.nth_exn pair 1)

let total_distance l1 l2 =
  let l1_sorted = List.stable_sort l1 ~compare:Int.compare in
  let l2_sorted = List.stable_sort l2 ~compare:Int.compare in
  let sorted_pairs = List.zip_exn l1_sorted l2_sorted in
  sorted_pairs
  |> List.map ~f:(fun p -> Int.abs (fst p - snd p))
  |> List.fold_left ~init:0 ~f:( + )

let occurrences l =
  List.sort_and_group l ~compare:Int.compare
  |> List.map ~f:(fun l -> (List.hd_exn l, List.length l))
  |> Map.of_alist_exn (module Int)

let similarity_score l1 l2 =
  let l2_occurrences = occurrences l2 in
  List.map l1 ~f:(fun n ->
      n * (Map.find l2_occurrences n |> Option.value ~default:0))
  |> List.fold_left ~init:0 ~f:( + )

let () =
  let pairs =
    In_channel.read_all "inputs/01.txt"
    |> String.rstrip |> String.split_lines |> List.map ~f:parse_pair
  in
  let l1, l2 = List.unzip pairs in
  let part1 = total_distance l1 l2 in
  let part2 = similarity_score l1 l2 in
  Stdio.printf "Part one: %d\nPart two: %d\n" part1 part2
