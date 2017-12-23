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

module Matrix = struct
  module T = struct
    type t = int array array
    [@@deriving sexp, compare]
  end

  include Comparable.Make(T)
  include T

  let create n = Array.make_matrix ~dimx:n ~dimy:n 0
end

let split n matrix =
  let num_splits = Array.length matrix / n in
  let matrixes = Array.init num_splits ~f:(fun _ ->
      Array.init num_splits ~f:(fun _ -> Matrix.create n)
    ) in
  Array.iteri matrix ~f:(fun y row ->
      Array.iteri row ~f:(fun x v ->
          matrixes.(y / n).(x / n).(y % n).(x % n) <- v
        )
    );
  matrixes

let join per_row matrixes =
  let n = Array.length matrixes in
  let m = Array.length matrixes.(0).(0) in
  let matrix = Matrix.create (n * m) in
  for y = 0 to n - 1 do
    for x = 0 to n - 1 do
      for iy = 0 to m - 1 do
        for ix = 0 to m -1 do
          matrix.(y * m + iy).(x * m + ix) <- matrixes.(y).(x).(iy).(ix)
        done
      done
    done
  done;
  matrix

let apply_rules rules matrixes =
  Array.map matrixes ~f:(Array.map ~f:(Map.find_exn rules))

let iter rules matrix =
  let size = Array.length matrix in
  let div = if Caml.(mod) size 2 = 0 then 2 else 3 in
  split div matrix
  |> apply_rules rules
  |> join (size / div)

let initial = ".#./..#/###" |> matrix_of_string

let () =
  let rules = In_channel.read_lines "21/input.txt"
              |> List.map ~f:rule_of_string
              |> List.map ~f:(fun (a, b) ->
                  List.map (permutations a) ~f:(fun m -> (m, b)))
              |> List.concat
              |> List.dedup ~compare:(fun (a, _) (b, _) -> Matrix.compare a b)
              |> Map.of_alist_exn (module Matrix)
  in
  let m = ref initial in
  for i = 0 to 17 do
    m := iter rules !m
  done;
  Array.fold !m ~init:0 ~f:(fun acc row ->
      acc + Array.count row ~f:((=) 1)
    )
  |> Stdio.printf "%d\n"
