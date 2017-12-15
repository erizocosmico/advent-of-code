open Base
open Stdio

type generator = { prev_value : int;
                   factor : int;
                   multiple: int;
                 }

let generator_a = { prev_value = 722; factor = 16807; multiple = 4 }
let generator_b = { prev_value = 354; factor = 48271; multiple = 8 }

let rec next gen =
  let value = Caml.(mod) (gen.prev_value * gen.factor) 2147483647 in
  let gen = { gen with prev_value = value } in
  if Caml.(mod) value gen.multiple = 0 then
    (gen, value)
  else
    next gen

let bin_of_int n bits =
  if n = 0 then List.range 0 bits |> List.map ~f:(fun _ -> 0)
  else
    let rec f acc n =
      if n = 0 then
        let len = List.length acc in
        if len < bits then
          let leading_zeros = List.range 0 (bits - len) |> List.map ~f:(fun _ -> 0) in
          List.append leading_zeros acc
        else
          acc
      else f ((n land 1) :: acc) (n lsr 1)
    in
    f [] n

let lowest_bits_equal a b =
  let a_bin = bin_of_int a 32 in
  let b_bin = bin_of_int b 32 in
  List.equal (List.drop a_bin 16) (List.drop b_bin 16) (=)

let matching_pairs gen_a gen_b num =
  let rec f gen_a gen_b remaining matching =
    if remaining = 0 then matching
    else
      let (gen_a, val_a) = next gen_a in
      let (gen_b, val_b) = next gen_b in
      let matching = if lowest_bits_equal val_a val_b then matching + 1 else matching in
      f gen_a gen_b (remaining - 1) matching
  in
  f gen_a gen_b num 0

let () =
  matching_pairs generator_a generator_b 5_000_000
  |> Stdio.printf "%d\n"
