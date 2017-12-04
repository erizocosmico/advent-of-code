open Base
open Stdio
open Caml

let is_even n = n mod 2 = 0

let data_pos n =
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

let steps n =
  let (x, y) = data_pos n in
  (abs x) + (abs y)

let input = 325489

let () =
  Stdio.printf "%d\n" (steps input)
