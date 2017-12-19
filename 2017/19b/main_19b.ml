open Base
open Stdio

type dir = Up | Left | Right | Down

let directions = [Up; Left; Right; Down]

let find_start_pos maze = 
  let x = Array.findi_exn maze.(0) ~f:(fun _ ch -> Char.equal ch '|')
          |> fst in
  (x, 0)

let next_pos (x, y) = function
  | Up -> (x, y - 1)
  | Left -> (x - 1, y)
  | Right -> (x + 1, y)
  | Down -> (x, y + 1)

let opposite = function 
  | Up -> Down 
  | Down -> Up 
  | Left -> Right
  | Right -> Left

let is_valid_path maze (x, y) = 
  x >= 0 && x < Array.length maze.(0) && y >= 0 && y < Array.length maze 
  && not (Char.equal maze.(y).(x) ' ')

let find_next_path_pos maze (x, y) dir =
  List.filter directions ~f:(fun d -> not (phys_equal d (opposite dir)))
  |> List.find ~f:(fun dir -> 
      let (x, y) = next_pos (x, y) dir in
      is_valid_path maze (x, y))(*next_pos (x, y) dir))*)
  |> Option.map ~f:(fun dir -> (next_pos (x, y) dir, dir))
  |> Option.value ~default:((-1, -1), Up)

exception Invalid_char of char

let rec follow_path maze steps (x, y) dir =
  if not (is_valid_path maze (x, y)) then
    (steps, (x, y), dir)
  else
    let c = maze.(y).(x) in
    if Char.equal c '+' then
      (steps + 1, (x, y), dir)
    else if Char.equal c ' ' then
      raise (Invalid_char c)
    else
      follow_path maze (steps + 1) (next_pos (x, y) dir) dir

let exit_maze maze =
  let start = find_start_pos maze in
  let rec aux steps pos dir =
    let (steps, pos, dir) = follow_path maze steps pos dir in
    if is_valid_path maze pos then
      let (pos, dir) = find_next_path_pos maze pos dir in
      aux steps pos dir
    else
      steps
  in
  aux 0 start Down

let () =
  In_channel.read_lines "19/input.txt"
  |> List.map ~f:(String.fold ~init:[] ~f:(fun acc ch -> ch :: acc))
  |> List.map ~f:Array.of_list_rev
  |> Array.of_list
  |> exit_maze
  |> Stdio.printf "%d\n"
