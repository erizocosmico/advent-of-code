open Stdio
open Base

let required_fuel x =
  let rec f x total =
    let v = (x / 3) - 2 in
    if v < 0 then total else f v (total + v)
  in
  f x 0

let () =
  let modules =
    In_channel.read_all "input.txt" |> String.rstrip |> String.split ~on:'\n'
  in
  modules
  |> List.map ~f:(fun x -> required_fuel (Int.of_string x))
  |> List.reduce_exn ~f:( + )
  |> Stdio.printf "%d"
