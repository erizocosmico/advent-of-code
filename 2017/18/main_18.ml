open Base
open Stdio

let value_of registers x = let fc = String.get x 0 in
  if Char.is_alpha fc then
    Map.find registers fc |> Option.value ~default:0
  else
    Caml.int_of_string x

let exec instructions =
  let registers = Map.empty (module Char) in
  let size = Array.length instructions in
  let rec aux registers instructions pos last_sound =
    if pos >= size then 0
    else
      let inst = Array.nget instructions pos in
      let parts = String.split inst ~on:' ' |> Array.of_list in
      let reg = String.get parts.(1) 0 in
      let x = value_of registers parts.(1) in
      match parts.(0) with
      | "snd" -> aux registers instructions (pos + 1) x
      | "set" -> 
        let registers = Map.add registers reg (value_of registers parts.(2)) in
        aux registers instructions (pos + 1) last_sound
      | "add" ->
        let registers = Map.add registers reg (x + value_of registers parts.(2)) in
        aux registers instructions (pos + 1) last_sound
      | "mul" ->
        let registers = Map.add registers reg (x * value_of registers parts.(2)) in
        aux registers instructions (pos + 1) last_sound
      | "mod" ->
        let registers = Map.add registers reg (Caml.(mod) x (value_of registers parts.(2))) in
        aux registers instructions (pos + 1) last_sound
      | "rcv" -> if x > 0 then last_sound
        else 
          aux registers instructions (pos + 1) last_sound
      | "jgz" -> 
        let new_pos = pos + if x > 0 then value_of registers parts.(2) 
                      else 1 in
        aux registers instructions new_pos last_sound
      | _ -> aux registers instructions (pos + 1) last_sound
  in
  aux registers instructions 0 0

let () =
  In_channel.read_lines "18/input.txt"
  |> Array.of_list
  |> exec
  |> Stdio.printf "%d\n"
