open Stdio
open Base

let rec indirect_orbits orbits x =
  match Map.find orbits x with
  | Some parent -> 1 + indirect_orbits orbits parent
  | None -> 0

let () =
  let orbits =
    In_channel.read_all "input.txt" 
    |> String.rstrip 
    |> String.split ~on:'\n'
    |> List.map ~f:(String.split ~on:')')
    |> List.map ~f:(fun x -> (List.last_exn x, List.hd_exn x))
    |> Map.of_alist_exn (module String)
  in
  Map.keys orbits
  |> List.map ~f:(indirect_orbits orbits)
  |> List.fold ~init:0 ~f:( + )
  |> Stdio.printf "%d\n"