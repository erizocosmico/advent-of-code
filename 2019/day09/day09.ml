open Stdio
open Base

exception Invalid_opcode of int
exception Invalid_param_mode of int

let int_of_char ch = (Char.to_int ch) - 48

module Computer = struct
  type t = {
    codes: int array;
    ptr: int;
    relative_base: int;
    input: int;
    output: int list;
    memory: (int, int) Hashtbl.t;
  }

  let make codes input = {
    codes = Array.copy codes;
    ptr = 0;
    relative_base = 0;
    input = input;
    output = [];
    memory = Hashtbl.create (module Int);
  }

  let next_opcode c =
    let code = Array.get c.codes c.ptr |> Int.to_string in
    let len = String.length code in
    let opcode = Int.of_string (
        if len >= 2 then
          String.drop_prefix code ((String.length code) - 2) 
        else code
      )
    in
    let param_modes = String.drop_suffix code 2 
                      |> String.to_list 
                      |> Array.of_list_rev 
                      |> Array.map ~f:int_of_char in
    (opcode, param_modes)

  let load_memory c pos =
    if pos >= Array.length c.codes then
      Hashtbl.find c.memory pos |> Option.value ~default:0
    else
      Array.get c.codes pos

  let store c pos v =
    if pos >= Array.length c.codes then
      Hashtbl.set c.memory ~key:pos ~data:v
    else
      Array.set c.codes pos v

  let param c param_modes idx =
    let p = load_memory c (c.ptr + idx + 1) in
    let mode = if Array.length param_modes > idx 
      then Array.get param_modes idx
      else 0 
    in
    match mode with
    | 0 -> load_memory c p
    | 1 -> p
    | 2 -> load_memory c (c.relative_base + p)
    | _ -> raise (Invalid_param_mode mode)

  let store_param c param_modes idx =
    let mode = if Array.length param_modes > idx 
      then Array.get param_modes idx
      else 0 
    in
    match mode with
    | 0 | 1 -> load_memory c (c.ptr + idx + 1)
    | 2 -> load_memory c (c.ptr + idx + 1) + c.relative_base
    | _ -> raise (Invalid_param_mode mode)

  let rec run c =
    let (opcode, param_modes) = next_opcode c in
    let store_param idx = store_param c param_modes idx in
    let param idx = param c param_modes idx in
    match opcode with
    | 1 | 2 ->
      let a = param 0 in
      let b = param 1 in
      let dst = store_param 2 in
      let op = if opcode = 1 then ( + ) else ( * ) in
      store c dst (op a b);
      run { c with ptr = c.ptr + 4 }
    | 3 ->
      store c (store_param 0) c.input;
      run { c with ptr = c.ptr + 2 }
    | 4 ->
      let v = param 0 in
      run { c with output = v :: c.output; ptr = c.ptr + 2}
    | 5 ->
      let ptr = if param 0 <> 0 then param 1 else c.ptr + 3 in
      run { c with ptr = ptr }
    | 6 ->
      let ptr = if param 0 = 0 then param 1 else c.ptr + 3 in
      run { c with ptr = ptr }
    | 7 ->
      let v = if param 0 < param 1 then 1 else 0 in
      store c (store_param 2) v;
      run { c with ptr = c.ptr + 4 }
    | 8 ->
      let v = if param 0 = param 1 then 1 else 0 in
      store c (store_param 2) v;
      run { c with ptr = c.ptr + 4 }
    | 9 ->
      run { c with ptr = c.ptr + 2; relative_base = c.relative_base + param 0 }
    | 99 -> c.output
    | opcode ->
      raise (Invalid_opcode opcode)
end

let () =
  let codes =
    In_channel.read_all "input.txt" 
    |> String.rstrip 
    |> String.split ~on:','
    |> List.map ~f:Int.of_string
    |> Array.of_list
  in
  let c = Computer.make codes 1 in
  Computer.run c
  |> List.rev_map ~f:Int.to_string
  |> String.concat ~sep:","
  |> Stdio.print_endline;;