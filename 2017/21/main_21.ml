open Base
open Stdio

let matrix_of_string str =
  let rows = String.split str '/' in
  let num_rows = List.length rows in
  List.map rows ~f:(fun row ->
      let r = Array.create num_rows 0 in
      String.foldi row ~init:r ~f:(fun j r col ->
          r.(j) <- if Char.equal col '#' then 1 else 0;
          r
        )
    )
  |> Array.of_list

let rule_of_string str = 
  let idx = String.substr_index_exn str " => " in
  let pattern = String.slice str 0 idx in
  let replacement = String.slice str (idx + 4) 0 in
  (matrix_of_string pattern, matrix_of_string replacement)

let flip_horizontal matrix =
  Array.map matrix ~f:(fun row -> let cp = Array.copy row in
                        Array.rev_inplace cp;
                        cp)

let flip_vertical matrix =
  let m = Array.map matrix ~f:Array.copy in
  Array.rev_inplace m;
  m

let rotate matrix =
  let size = Array.length matrix in
  Array.mapi matrix ~f:(fun i row ->
      Array.mapi row ~f:(fun j _ -> matrix.(size - 1 - j).(i))
    )

let permutations matrix =
  let m1 = rotate matrix in
  let m2 = rotate m1 in
  let m3 = rotate m2 in
  [matrix; flip_vertical matrix; flip_horizontal matrix; 
   m1; flip_vertical m1; flip_horizontal m1;
   m2; flip_vertical m2; flip_horizontal m2;
   m3; flip_vertical m3; flip_horizontal m3]

let equals m1 m2 = Array.length m1 = Array.length m2 &&
                   Array.equal m1 m2 ~equal:(Array.equal ~equal:(=))

let split n matrix =
  let num_splits = Array.length matrix / n in
  let rec split matrixes i j =
    if i >= num_splits || j >= num_splits then
      matrixes
    else
      let m = Array.mapi (Array.create n 0) ~f:(fun si _ ->
          Array.create n 0
          |> Array.mapi ~f:(fun sj _ -> matrix.(i * n + si).(j * n + sj))
        )
      in
      let i = if (num_splits - 1) = j then i + 1 else i in
      let j = if (num_splits - 1) = j then 0 else j + 1 in
      split (List.append matrixes [m]) i j
  in
  split [] 0 0

let join per_row matrixes =
  List.groupi matrixes ~break:(fun i _ _ -> (Caml.(mod) i per_row) = 0)
  |> List.map ~f:(fun g ->
      List.reduce_exn g ~f:(fun a b ->
          Array.mapi a ~f:(fun i r -> Array.append r b.(i))))
  |> List.reduce_exn ~f:Array.append

let apply_rules rules m =
  Option.value_exn (List.find rules ~f:(fun (a, _) -> equals m a))
  |> snd

let iter rules matrix =
  let size = Array.length matrix in
  let div = if Caml.(mod) size 2 = 0 then 2 else 3 in
  split div matrix
  |> List.map ~f:(apply_rules rules)
  |> join (size / div)

let initial = ".#./..#/###" |> matrix_of_string

let () =
  let rules = In_channel.read_lines "21/input.txt"
              |> List.map ~f:rule_of_string
              |> List.map ~f:(fun (a, b) ->
                  List.map (permutations a) ~f:(fun m -> (m, b)))
              |> List.concat
  in
  let m = ref initial in
  for i = 0 to 4 do
    m := iter rules !m
  done;
  Array.fold !m ~init:0 ~f:(fun acc row ->
      acc + Array.count row ~f:((=) 1)
    )
  |> Stdio.printf "%d\n"
