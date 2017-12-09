open Base
open Stdio

type content = Group of content list | Garbage of char list

exception Expecting_chars of char list

let parse_garbage chars =
  let rec parse chars garbage =
    match List.hd_exn chars with
    | '>' -> (Garbage garbage, List.tl_exn chars)
    | '!' -> parse (List.drop chars 2) garbage
    | ch -> parse (List.tl_exn chars) (List.append garbage [ch])
  in
  (** < is already read in parse_group_content *)
  parse (List.tl_exn chars) []

let parse_group_content chars parse_group =
  let rec parse chars content =
    let c = List.hd_exn chars in
    match c with
    | '{' -> 
      let (group, remaining) = parse_group chars in
      parse remaining (List.append content [group])
    | '}' -> (content, chars)
    | ',' -> parse (List.tl_exn chars) content
    | '<' -> 
      let (garbage, remaining) = parse_garbage chars in
      parse remaining (List.append content [garbage])
    | _ -> raise (Expecting_chars ['{'; '}'; ','; '<'])
  in
  parse chars []

let rec parse_group chars =
  if Char.equal (List.hd_exn chars) '{' |> not then
    raise (Expecting_chars ['{'])
  else
    let (content, remaining) = parse_group_content (List.tl_exn chars) parse_group in
    if Char.equal (List.hd_exn remaining) '}' |> not then
      raise (Expecting_chars ['}'])
    else
      (Group content, List.tl_exn remaining)

exception Unparsed_content of string

let parse_stream stream = 
  let chars = stream |> String.to_list in
  let (group, remaining) = parse_group chars in
  if not (List.is_empty remaining) then
    raise (Unparsed_content (String.of_char_list remaining))
  else
    group

let stream_score content = 
  let rec group_score prev = function
    | Garbage _ -> 0
    | Group inner -> 
      let score = 1 + prev in
      inner |> List.map ~f:(group_score score) 
      |> List.reduce ~f:(+) 
      |> Option.value ~default:0
      |> (+) score
  in
  group_score 0 content

let () =
  let stream = In_channel.read_all "09/input.txt" in
  stream |> parse_stream |> stream_score |> Stdio.printf "%d\n"
