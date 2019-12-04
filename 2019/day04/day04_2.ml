open Base

let decreases pwd =
  List.group pwd ~break:( < )
  |> List.length > 1

let has_double pwd =
  List.group pwd ~break:(<>)
  |> List.exists ~f:(fun g -> List.length g = 2)

let meets_criteria pwd =
  let pwd = Int.to_string pwd
            |> String.to_list_rev
            |> List.map ~f:Char.to_int in
  not (decreases pwd) && has_double pwd

let () =
  let (start, stop) = (265275, 781584) in
  List.range start stop
  |> List.count ~f:meets_criteria
  |> Stdio.printf "%d\n"