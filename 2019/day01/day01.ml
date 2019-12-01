open Stdio
open Base

let () =
  let modules =
    In_channel.read_all "input1.txt" |> String.rstrip |> String.split ~on:'\n'
  in
  modules
  |> List.map ~f:(fun x -> (Int.of_string x / 3) - 2)
  |> List.reduce_exn ~f:( + )
  |> Stdio.printf "%d"