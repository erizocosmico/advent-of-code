open Base
open Stdio

module Component = struct
  module T = struct
    type t = int * int [@@deriving sexp, compare]
  end

  include Comparable.Make(T)
  include T

  let has_connector n (a, b) = Int.equal n a || Int.equal n b

  let of_string str = match String.split str ~on:'/' with
    | [a; b] -> (Caml.int_of_string a, Caml.int_of_string b)
    | _ -> raise (Invalid_argument str)
end

let all_bridges components =
  let rec f bridges connector remaining =
    let candidates = Set.filter remaining ~f:(Component.has_connector connector) in
    if Set.is_empty candidates then [bridges]
    else
      Set.fold candidates ~init:[] ~f:(fun acc (a, b) ->
          let remaining = Set.remove remaining (a, b) in
          let connector = if connector = a then b else a in
          List.append (f ((a, b) :: bridges) connector remaining) acc
        )
  in
  f [] 0 (Set.of_list (module Component) components)

let strength bridge = List.map bridge ~f:(fun (a, b) -> a + b)
                      |> List.reduce_exn ~f:(+)

let cmp_bridge a b = Int.compare (strength a) (strength b)

let () =
  let components = In_channel.read_lines "24/input.txt"
                   |> List.map ~f:Component.of_string
  in
  let bridges = all_bridges components in
  Option.value_exn (List.max_elt bridges ~cmp:cmp_bridge)
  |> strength
  |> Stdio.printf "%d\n"
