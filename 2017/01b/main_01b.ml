open Stdio
open Base

let read_file name = name
  |> In_channel.read_all
  |> String.rstrip

let ascii_zero = 48

let get_int str idx =
  (String.get str idx |> Char.to_int) - ascii_zero

let solve input =
  let digits = Array.init (String.length input) (get_int input) in
  let num_digits = Array.length digits in
  let step = num_digits / 2 in
  let next_idx idx = if (idx + step) >= num_digits then
    idx + step - num_digits
  else
    idx + step in
  digits
    |> Array.mapi ~f:(fun idx ch ->
        if ch = Array.nget digits (next_idx idx) then ch else 0)
    |> Array.reduce_exn ~f:(+)

let () =
  let input = read_file "01/input.txt" in
printf "%d\n" (solve input)
