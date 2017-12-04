open Base
open Stdio

let cmp_anagram a b =
  let sorted_chars str = str |> String.to_list 
                         |> List.sort ~cmp:(Char.compare) 
                         |> String.of_char_list in
  String.compare (sorted_chars a) (sorted_chars b)

let is_valid_passphrase phrase =
  not (String.split ~on:' ' phrase 
       |> List.contains_dup ~compare:cmp_anagram)

let () =
  In_channel.read_lines "04/input.txt"
  |> List.filter ~f:(is_valid_passphrase)
  |> List.length
  |> Stdio.printf "%d\n"
