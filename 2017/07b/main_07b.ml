open Base
open Stdio

type program = {
  name : string;
  weight : int;
  children : string list;
}

let remove_parens str = String.drop_prefix (String.drop_suffix str 1) 1

let remove_comma str = 
  if String.is_suffix str "," then String.drop_suffix str 1 else str

let program_of_string s = 
  let parts = s |> String.split ~on:' ' in
  {name = List.hd_exn parts;
   weight = List.nth_exn parts 1 |> remove_parens |> Caml.int_of_string;
   children = if List.length parts > 3 then
       List.drop parts 3 |> List.map ~f:remove_comma
     else
       []
  }

let relationships_of_program {name = parent_name; children} =
  List.map children ~f:(fun name -> (name, parent_name))

let is_parent {children} = not (List.is_empty children)

let find_bottom parents relationships =
  List.find_exn parents ~f:(fun {name} -> not (Map.mem relationships name))

type tower_weight = Balanced of int * int | Imbalanced of int * int *int

let is_imbalanced = function | Imbalanced _ -> true | _ -> false

let get_weight = function | Imbalanced _ -> 0 | Balanced (parent, childs) -> parent + childs

let find_imbalance bottom programs relationships =
  let rec tower_imbalance parent =
    let children = Map.filter relationships (String.equal parent) |> Map.keys in
    let weight = (Map.find_exn programs parent).weight in
    if List.is_empty children then
      Balanced (weight, 0)
    else
      let results = children |> List.map ~f:tower_imbalance in
      match List.find results is_imbalanced with
      | Some imbalance -> imbalance
      | None ->
        let groups = results |> List.group ~break:(fun a b -> get_weight a <> get_weight b) in
        if List.length groups > 1 then
          let target = groups |> List.find_exn ~f:(fun l -> List.length l > 1) 
                       |> List.hd_exn
                       |> get_weight in
          let wrong = groups |> List.find_exn ~f:(fun l -> List.length l = 1) 
                      |> List.hd_exn in
          match wrong with 
          | Balanced (p, c) -> Imbalanced (p, c, target)
          | q -> q
        else
          Balanced (weight, groups |> List.concat 
                            |> List.map ~f:get_weight 
                            |> List.reduce_exn ~f:(+))
  in
  match tower_imbalance bottom with
  | Balanced _ -> None
  | Imbalanced (parent, children, target) -> Some (parent, children, target)

let () =
  let programs = In_channel.read_lines "07/input.txt" 
                 |> List.map ~f:(fun l -> let p = program_of_string l in (p.name, p))
                 |> Map.of_alist_exn (module String) in
  let parents = Map.filter programs is_parent |> Map.data in
  let relationships = parents |> List.map ~f:relationships_of_program 
                      |> List.concat
                      |> Map.of_alist_exn (module String) in
  let {name = bottom} = find_bottom parents relationships in
  match find_imbalance bottom programs relationships with
  | None -> Stdio.print_endline "is balanced"
  | Some (parent, children, target) -> 
    Stdio.printf "%d\n" (parent + target - (parent + children))