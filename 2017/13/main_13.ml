open Base
open Stdio

type layer = Empty | Scanner of int

let firewall_of_scanners scanners =
  let max = Map.keys scanners |> List.max_elt ~cmp:Int.compare
            |> Option.value ~default:0 in
  Array.create ~len:(max + 1) (Empty)
  |> Array.mapi ~f:(fun i v -> if Map.mem scanners i then
                       Scanner (Map.find_exn scanners i)
                     else
                       v)

let caught depth picosecond = Caml.(mod) picosecond (depth * 2 - 2) = 0

let trip_severity firewall =
  Array.mapi firewall ~f:(fun idx layer -> match layer with
      | Empty -> 0
      | Scanner depth -> if caught depth idx then depth * idx else 0
    )
  |> Array.reduce_exn ~f:(+)

let () =
  let firewall = In_channel.read_lines "13/input.txt"
                 |> List.map ~f:(String.split ~on:':')
                 |> List.map ~f:(fun ls -> 
                     let layer = List.hd_exn ls |> Caml.int_of_string in
                     let depth = List.hd_exn (List.drop ls 1) 
                                 |> String.chop_prefix_exn ~prefix:" " 
                                 |> Caml.int_of_string in
                     (layer, depth)
                   )
                 |> Map.of_alist_exn (module Int)
                 |> firewall_of_scanners
  in
  firewall |> trip_severity |> Stdio.printf "%d\n"
