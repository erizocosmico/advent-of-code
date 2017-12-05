open Base
open Stdio

let transform_line line =
  String.split line '\t' |> List.map ~f:Caml.int_of_string

let read_input name =
  In_channel.read_lines name |> List.map ~f:transform_line

let line_division nums =
  let rec find hd tl =
    let res = List.find_map tl ~f:(fun n -> if hd mod n = 0 then
                                      Some(hd / n)
                                    else if n mod hd = 0 then
                                      Some(n / hd)
                                    else
                                      None) in
    match res with
    | Some(n) -> n
    | None -> find (List.nth_exn tl 0) (List.drop tl 1)
  in
  find (List.nth_exn nums 0) (List.drop nums 1)

let checksum input =
  List.map input line_division |> List.reduce_exn ~f:(+)

let () =
  let input = read_input "02/input.txt" in
  Stdio.printf "%d\n" (checksum input)
