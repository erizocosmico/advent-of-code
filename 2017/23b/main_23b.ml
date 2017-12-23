open Base
open Stdio

exception Exit

let () =
  let h = ref 0 in
  let b = 109300 in
  let c = 126300 in
  List.iter (List.range b (c + 1) ~stride:17) ~f:(fun x ->
      try
        for i = 2 to (x - 1) do
          if (Caml.(mod) x i) = 0 then
            raise Exit
        done
      with Exit -> Caml.incr h);
  Stdio.printf "%d\n" !h

