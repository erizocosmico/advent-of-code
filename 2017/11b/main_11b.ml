open Base
open Stdio

type direction = North | NorthWest | NorthEast
               | South | SouthWest | SouthEast

exception Invalid_direction of string

let direction_of_string = function
  | "n" -> North
  | "nw" -> NorthWest
  | "ne" -> NorthEast
  | "s" -> South
  | "sw" -> SouthWest
  | "se" -> SouthEast
  | d -> raise (Invalid_direction d)

let move (a, b) direction = 
  match direction with
  | North -> (a, b - 1)
  | NorthWest -> (a - 1, b)
  | NorthEast -> (a + 1, b - 1)
  | South -> (a, b + 1)
  | SouthWest -> (a - 1, b + 1)
  | SouthEast -> (a + 1, b)

let distance (a, b) = ((Int.abs a) + (Int.abs (a + b)) + (Int.abs b)) / 2

let max_distance directions =
  let f (pos, max_distance) direction =
    let new_pos = move pos direction in
    let distance = distance new_pos in
    (new_pos, if distance > max_distance then distance else max_distance)
  in
  let (_, max_distance) = List.fold_left directions ~init:((0, 0), 0) ~f:f in
  max_distance

let () =
  let directions = In_channel.read_all "11/input.txt"
                   |> String.split ~on:','
                   |> List.map ~f:direction_of_string
  in
  max_distance directions |> Stdio.printf "%d\n"
