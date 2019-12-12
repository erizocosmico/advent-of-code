open Stdio
open Base

let parse_map rows =
  List.map rows ~f:(fun r -> String.to_list r |> Array.of_list)
  |> Array.of_list

let angle x1 y1 x2 y2 =
  let dx = Float.of_int (x2 - x1) in
  let dy = Float.(-) 0.0 (Float.of_int (y2 - y1)) in
  let rads = Float.atan2 dy dx in
  let n = if Float.( < ) rads 0.0 then
      Float.abs rads
    else
      Float.( * ) (Float.( * ) Float.pi rads) 2.0 in
  Float.( / ) (Float.( * ) n 180.0) Float.pi

let reachable_asteroids map station_pos =
  let (sx, sy) = station_pos in
  let reached = Hash_set.create ~size:0 ~growth_allowed:true (module Float) in
  Array.iteri map ~f:(fun y row ->
      Array.iteri row ~f:(fun x c ->
          let is_asteroid = Char.equal c '#' in
          let is_station = x = sx && y = sy in
          let angle = angle sx sy x y in
          if is_asteroid && not is_station then
            Hash_set.add reached angle
        )
    );
  Hash_set.length reached

let solve map =
  Array.mapi map ~f:(fun y row ->
      Array.foldi row ~init:[] ~f:(fun x acc c ->
          if Char.equal c '#' then
            reachable_asteroids map (x, y) :: acc
          else
            acc
        )
      |> List.max_elt ~compare:Int.compare 
      |> Option.value ~default:0
    )
  |> Array.to_list
  |> List.max_elt ~compare:Int.compare
  |> Option.value ~default:0

let () =
  let map = In_channel.read_all "input.txt" 
            |> String.rstrip 
            |> String.split ~on:'\n'
            |> parse_map in
  solve map
  |> Stdio.printf "%d\n"