open Base
open Stdio

module Vector3d = struct
  type t = int * int * int

  let sum (x1, y1, z1) (x2, y2, z2) = (x1 + x2, y1 + y2, z1 + z2)

  let distance (x, y, z) = (Int.abs x) + (Int.abs y) + (Int.abs z)

  exception Invalid_vector of string

  let of_string str = String.split str ~on:','
                      |> List.map ~f:Caml.int_of_string
                      |> (function | x :: y :: z :: [] -> (x, y, z)
                                   | _ -> raise (Invalid_vector str))
end

type particle = {
  id: int;
  position: Vector3d.t;
  velocity: Vector3d.t;
  acceleration: Vector3d.t;
}

exception Invalid_particle of string

let particle_of_string id str =
  let parts = String.split str ~on:' '
              |> List.map ~f:(fun x ->
                  let x = String.chop_suffix x "," |> Option.value ~default:x in
                  String.drop_suffix (String.drop_prefix x 3) 1
                  |> Vector3d.of_string)
  in
  match parts with
  | p :: v :: a :: [] -> {id; position = p; velocity = v; acceleration = a}
  | _ -> raise (Invalid_particle str)

let tick {id; position; velocity; acceleration} =
  let velocity = Vector3d.sum velocity acceleration in
  let position = Vector3d.sum position velocity in
  {id; position; velocity; acceleration}

let () =
  let particles = In_channel.read_lines "20/input.txt"
                  |> List.mapi ~f:particle_of_string
                  |> ref
  in
  for _ = 0 to List.length !particles do
    particles := List.map !particles tick
  done;
  let {id} = List.sort !particles ~cmp:(fun a b ->
      Vector3d.distance a.position - Vector3d.distance b.position)
             |> List.hd_exn
  in
  Stdio.printf "%d\n" id
