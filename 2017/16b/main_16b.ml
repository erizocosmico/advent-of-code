open Base
open Stdio

let tuple2_of_list ls = (List.hd_exn ls, List.nth_exn ls 1)

let swap i j line = Array.swap line i j; line

let char_pos line ch = 
  Array.findi_exn line ~f:(fun _ x -> Char.equal ch x) |> fst

let spin line n =
  let size = Array.length line in
  let front = Array.slice line (size - n) 0 in
  let back = Array.slice line 0 (size - n) in
  Array.append front back

let move line move = match String.get move 0 with
  | 'x' -> let (i, j) = String.drop_prefix move 1
                        |> String.split ~on:'/'
                        |> List.map ~f:Caml.int_of_string
                        |> tuple2_of_list in
    swap i j line
  | 'p' -> let (a, b) = String.drop_prefix move 1
                        |> String.split ~on:'/'
                        |> List.map ~f:(fun x -> String.get x 0)
                        |> tuple2_of_list in
    swap (char_pos line a) (char_pos line b) line
  | 's' -> let size = String.drop_prefix move 1 |> Caml.int_of_string in
    spin line size
  | _ -> line

let () =
  let start_char = Char.to_int 'a' in  
  let original_line = List.range 0 16 
                      |> Array.of_list 
                      |> Array.map ~f:(fun n -> Char.of_int_exn (start_char + n))
  in
  let moves = In_channel.read_all "16/input.txt" 
              |> String.split ~on:',' in
  let rec find_cycle line n = 
    if n > 0 && Array.equal line original_line Char.equal then
      n
    else
      find_cycle (List.fold_left moves ~init:line ~f:move) (n + 1)
  in
  let n = find_cycle (Array.copy original_line) 0 in
  let rec repeat_moves line n = if n = 0 then
      line 
    else
      repeat_moves (List.fold_left moves ~init:line ~f:move) (n - 1)
  in
  repeat_moves original_line (Caml.(mod) 1_000_000_000 n)
  |> Array.fold ~init:"" ~f:(fun acc ch -> acc ^ String.of_char ch)
  |> Stdio.print_endline
