open Base
open Stdio

let spinlock steps =
  let rec step buf pos size v =
    let new_pos = Caml.(mod) (pos + steps) size in
    let front = List.take buf (new_pos + 1) in
    let back = List.drop buf (new_pos + 1) in
    let buf = List.append front (v :: back) in
    if v = 2017 then buf
    else step buf (new_pos + 1) (size + 1) (v + 1)
  in
  step [0] 0 1 1

let steps = 345

let () =
  let buf = spinlock steps in
  let idx = List.findi buf ~f:(fun i x -> x = 2017) 
            |> Option.value ~default:(0, 0) 
            |> fst in
  List.nth_exn buf (idx + 1) |> Stdio.printf "%d\n"
