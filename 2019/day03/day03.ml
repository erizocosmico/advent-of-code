open Stdio
open Base

let abs x = if x < 0 then -x else x

exception Invalid_direction of char

module Pos = struct
  type t = int * int [@@deriving compare, sexp_of, hash]

  let distance pos = (abs (fst pos)) + (abs (snd pos))
end

let add_pos map id x y = Hashtbl.change map (x, y) ~f:(
    fun prev -> match prev with
      | Some x -> Some (List.dedup_and_sort ~compare:Int.compare (id :: x))
      | None -> Some [id]
  )

let follow_wire map id wire =
  let x = ref 0 in
  let y = ref 0 in
  List.iter wire ~f:(fun step -> 
      let n = Int.of_string (String.drop_prefix step 1) in
      match String.get step 0 with
      | 'R' -> 
        for nx = !x to !x + n do
          add_pos map id nx !y
        done;
        x := !x + n
      | 'L' ->
        for nx = !x downto !x - n do
          add_pos map id nx !y
        done;
        x := !x - n
      | 'U' -> 
        for ny = !y to !y + n do
          add_pos map id !x ny
        done;
        y := !y + n
      | 'D' ->
        for ny = !y downto !y - n do
          add_pos map id !x ny
        done;
        y := !y - n
      | d -> raise (Invalid_direction d)
    )


let () =
  let wires =
    In_channel.read_all "input.txt" 
    |> String.rstrip 
    |> String.split ~on:'\n'
    |> List.map ~f:(String.split ~on:',')
  in
  let map = Hashtbl.create (module Pos) in
  List.iteri wires ~f:(follow_wire map);
  Hashtbl.filter ~f:(fun x -> (List.length x) > 1) map
  |> Hashtbl.keys
  |> List.map ~f:Pos.distance
  |> List.filter ~f:(fun x -> x > 0)
  |> List.sort ~compare:Int.compare
  |> List.hd_exn
  |> Stdio.printf "%d"