open Base
open Stdio

let is_valid_passphrase phrase =
  not (String.split ~on:' ' phrase |> List.contains_dup)

let () =
  In_channel.read_lines "04/input.txt"
  |> List.filter ~f:(is_valid_passphrase)
  |> List.length
  |> Stdio.printf "%d\n"
