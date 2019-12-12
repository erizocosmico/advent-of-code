open Stdio
open Base

type point3d = {
  x: int;
  y: int;
  z: int;
}

type moon = {
  pos: point3d;
  vel: point3d;
}

let parse_moon line =
  let components = String.drop_suffix (String.drop_prefix line 1) 1
                   |> String.split ~on:','
                   |> List.map ~f:(fun part ->
                       String.split part ~on:'='
                       |> List.last_exn
                       |> Int.of_string)
                   |> Array.of_list
  in
  let pos = {x = components.(0); y = components.(1); z = components.(2)} in
  let vel = {x = 0; y = 0; z = 0} in
  {pos = pos; vel = vel}

let gravity_increment a b =
  if a < b then 1
  else if a > b then -1
  else 0

let velocity_after_gravity p1 p2 vel =
  {x = vel.x + gravity_increment p1.x p2.x;
   y = vel.y + gravity_increment p1.y p2.y;
   z = vel.z + gravity_increment p1.z p2.z}

let apply_gravity_to_system moons = Array.iteri moons ~f:(fun i m1 ->
    let vel = ref m1.vel in
    Array.iteri moons ~f:(fun j m2 ->
        if i <> j then
          vel := velocity_after_gravity m1.pos m2.pos !vel
      );
    moons.(i) <- {moons.(i) with vel = !vel}
  )


let simulate moons steps =
  for _ = 1 to steps do
    apply_gravity_to_system moons;
    Array.iteri moons ~f:(fun i m ->
        moons.(i) <- {m with pos = {x = m.pos.x + m.vel.x;
                                    y = m.pos.y + m.vel.y;
                                    z = m.pos.z + m.vel.z}}
      )
  done

let abs n = if n < 0 then -n else n

let system_energy moons =
  Array.map moons ~f:(fun m ->
      let pot = abs(m.pos.x) + abs(m.pos.y) + abs(m.pos.z) in
      let kin = abs(m.vel.x) + abs(m.vel.y) + abs(m.vel.z) in
      pot * kin
    )
  |> Array.fold ~init:0 ~f:( + )

let () =
  let moons =
    In_channel.read_all "input.txt" 
    |> String.rstrip 
    |> String.split ~on:'\n'
    |> List.map ~f:parse_moon
    |> Array.of_list
  in
  simulate moons 1000;
  Stdio.printf "%d\n" (system_energy moons)