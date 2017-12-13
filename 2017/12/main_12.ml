open Base
open Stdio

let in_group relationships id =
  let rec f seen id =
    let related = relationships
                  |> Map.filteri ~f:(fun ~key ~data -> 
                      Set.mem data id && not (Set.mem seen key))
                  |> Map.keys
    in
    if List.is_empty related then
      seen
    else
      related
      |> List.fold_left ~init:seen ~f:(fun seen id -> f (Set.add seen id) id)
  in
  f (Set.singleton (module Int) 0) 0

let relationship_of_string s =
  let parts = s |> String.split ~on:' ' in
  let from = List.hd_exn parts |> Caml.int_of_string in
  let ids = List.drop parts 2 
            |> List.map ~f:(fun s -> String.chop_suffix s "," |> Option.value ~default:s)
            |> List.map ~f:Caml.int_of_string
  in
  (from, Set.of_list (module Int) ids)

let () =
  let relationships = In_channel.read_lines "12/input.txt"
                      |> List.map ~f:relationship_of_string
                      |> Map.of_alist_exn (module Int)
  in
  in_group relationships 0 |> Set.length |> Stdio.printf "%d\n"
