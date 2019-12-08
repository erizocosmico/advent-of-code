open Stdio
open Base

let layers data wide tall =
  let n = wide * tall in
  let rec f data layers =
    match data with
    | [] -> layers
    | x -> f (List.drop x n) ((List.take x n) :: layers)
  in
  f data []


let apply_layer data wide tall layer =
  for y = 0 to tall-1 do
    for x = 0 to wide-1 do
      match Array.get layer (y * wide + x) with
      | 0 | 1 as n -> data.(x).(y) <- n
      | _ -> ()
    done
  done

let () =
  let data =
    In_channel.read_all "input.txt" 
    |> String.rstrip
    |> String.to_list
    |> List.map ~f:(fun c -> Char.to_int c - 48)
  in
  let (wide, tall) = (25, 6) in
  let layers = layers data wide tall |> List.map ~f:Array.of_list in
  let image = Array.make_matrix ~dimx:wide ~dimy:tall 0 in
  List.iter layers ~f:(apply_layer image wide tall);
  for y = 0 to tall-1 do
    for x = 0 to wide-1 do
      Stdio.printf "%s" (if image.(x).(y) = 1 then "#" else " ")
    done;
    Stdio.printf "\n"
  done;;
