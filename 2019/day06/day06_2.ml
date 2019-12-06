open Stdio
open Base

let rec orbit_path orbits x =
  match Map.find orbits x with
  | Some parent -> parent :: orbit_path orbits parent
  | None -> []

let rec diff l1 l2 =
  let (a, b) = (List.hd_exn l1, List.hd_exn l2) in
  if String.equal a b then
    diff (List.drop l1 1) (List.drop l2 1)
  else
    (List.length l1) + (List.length l2)

let transfers orbits from dst =
  diff (orbit_path orbits from |> List.rev) (orbit_path orbits dst |> List.rev)

let () =
  let orbits =
    In_channel.read_all "input.txt" 
    |> String.rstrip 
    |> String.split ~on:'\n'
    |> List.map ~f:(String.split ~on:')')
    |> List.map ~f:(fun x -> (List.last_exn x, List.hd_exn x))
    |> Map.of_alist_exn (module String)
  in
  Stdio.printf "%d\n" (transfers orbits "YOU" "SAN")