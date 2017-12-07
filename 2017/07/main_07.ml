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

let find_bottom programs =
  let parents = List.filter programs (fun {children} -> not (List.is_empty children)) in
  let relationships = parents |> List.map ~f:relationships_of_program 
                      |> List.concat 
                      |> Map.of_alist_exn (module String) in
  List.find_exn parents ~f:(fun {name} -> not (Map.mem relationships name))

let () =
  let programs = In_channel.read_lines "07/input.txt" 
                 |> List.map ~f:program_of_string in
  let {name} = find_bottom programs in
  Stdio.print_endline name