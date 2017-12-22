open Base
open Stdio

type dir = Up | Right | Down | Left

let turn_left = function 
  | Up -> Left
  | Right -> Up
  | Down -> Right
  | Left -> Down

let turn_right = function
  | Up -> Right
  | Right -> Down
  | Down -> Left
  | Left -> Up

type carrier = {
  dir: dir;
  pos: int * int;
}

module Point = struct
  type t = int * int
  include Comparator.Make (struct
      type t = int * int
      let sexp_of_t _ = Sexp.Atom "_"
      let compare (x1, y1) (x2, y2) =
        match Int.compare x1 x2 with
        | 0 -> Int.compare y1 y2
        | n -> n
    end)
end

let move {dir; pos = (x, y)} =
  match dir with
  | Up -> {dir; pos = (x, y - 1)}
  | Left -> {dir; pos = (x - 1, y)}
  | Down -> {dir; pos = (x, y + 1)}
  | Right -> {dir; pos = (x + 1, y)}

let activity_burst grid carrier =
  let (x, y) = carrier.pos in
  let should_infect = (Map.find grid (x, y) |> Option.value ~default:0) = 0 in
  let (dir, status) = if not should_infect then
      (turn_right carrier.dir, 0)
    else
      (turn_left carrier.dir, 1)
  in
  let grid = Map.add grid (x, y) status in
  (grid, move {carrier with dir}, should_infect)

let run n grid center =
  let rec f grid carrier n infections =
    if n = 0 then
      infections
    else
      let (grid, carrier, infected) = activity_burst grid carrier in
      f grid carrier (n - 1) (infections + (if infected then 1 else 0))
  in
  f grid {dir = Up; pos = center} n 0

let infinite_grid grid =
  List.foldi grid ~init:(Map.empty (module Point)) ~f:(fun y acc row ->
      String.foldi row ~init:acc ~f:(fun x acc v -> 
          if Char.equal v '#' then Map.add acc (x, y) 1
          else acc)
    )

let () =
  let grid = In_channel.read_lines "22/input.txt" in
  let inf_grid = infinite_grid grid in
  let center_x = (grid |> List.hd_exn |> String.length) / 2 in
  let center_y = (grid |> List.length) / 2 in
  run 10_000 inf_grid (center_x, center_y)
  |> Stdio.printf "%d\n"
