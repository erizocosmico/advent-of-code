open Base
open Caml
open Stdio

let is_even n = n mod 2 = 0

let square_pos n =
  let side = n |> float |> sqrt |> ceil |> truncate in
  let corner = side * side in
  let past_corner = corner - (side - 1) in
  if is_even side then
    let corner_x = - (side / 2 - 1) in
    let corner_y = side / 2 in
    if past_corner > n then
      (corner_x + (side - 1), corner_y - (past_corner - n))
    else
      (corner_x + (corner - n), corner_y)
  else
    let corner_x = side / 2 in
    let corner_y = - corner_x in
    if past_corner > n then
      (corner_x - (side - 1), corner_y + (past_corner - n))
    else
      (corner_x - (corner - n), corner_y)

let adjacent_matrix = [
  (-1, 1);  (0, 1);  (1, 1);
  (-1, 0);           (1, 0);
  (-1, -1); (0, -1); (1, -1);
]

let find_adjacents spiral (x, y) =
  adjacent_matrix
  |> Base.List.filter_map ~f:(fun (x1, y1) -> Hashtbl.find_opt spiral (x + x1, y + y1))

let spiral_num_after target =
  let spiral = Hashtbl.create 100 in
  Hashtbl.add spiral (0, 0) 1;
  let rec next_number n =
    let new_pos = square_pos n in
    let new_val = find_adjacents spiral new_pos |> List.fold_left (+) 0 in
    Hashtbl.add spiral new_pos new_val;
    if new_val > target then
      new_val
    else
      next_number (n + 1) in
  next_number 2

let target_num = 325489

let () =
  Stdio.printf "%d\n" (spiral_num_after target_num)

