open Stdio
open Base

let layers data wide tall =
  let n = wide * tall in
  let rec f data layers =
    match data with
    | [] -> layers
    | x -> f (List.drop x n) ((List.take x n) :: layers)
  in
  f data []


let count_digits ls n =
  List.count ls ~f:(fun d -> d = n)

let cmp_num_zeros a b =
  Int.compare (count_digits a 0) (count_digits b 0)


let () =
  let data =
    In_channel.read_all "input.txt" 
    |> String.rstrip
    |> String.to_list
    |> List.map ~f:(fun c -> Char.to_int c - 48)
  in
  let (wide, tall) = (25, 6) in
  let layers = layers data wide tall in
  let layer = List.stable_sort layers ~compare:cmp_num_zeros
              |> List.hd_exn
  in
  (count_digits layer 1 * count_digits layer 2)
  |> Stdio.printf "%d\n"
