open Base
open Stdio

let spinlock steps =
  let rec step pos size v after_0 =
    let new_pos = Caml.(mod) (pos + steps) size in
    if v = 50_000_000 then 
      after_0
    else 
      step (new_pos + 1) (size + 1) (v + 1) (if new_pos = 0 then v else after_0)
  in
  step 0 1 1 0

let steps = 345

let () =
  spinlock steps |>Stdio.printf "%d\n"
