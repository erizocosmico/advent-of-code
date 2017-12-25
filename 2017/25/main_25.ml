open Base
open Stdio

type machine = {
  tape: (int, int, Int.comparator_witness) Map.t;
  cursor: int;
  state: state;
}
and update = {
  write: int;
  move: int;
  next_state: state;
} 
and state = State of update * update

let current_value tape cursor =
  Map.find tape cursor |> Option.value ~default:0

let run_state {tape; cursor; state} = 
  let State(zero, one) = state in
  let {write; move; next_state} = if current_value tape cursor = 0 then zero else one in
  {
    tape = Map.add tape cursor write;
    cursor = cursor + move;
    state = next_state;
  }

let rec state_a = State (
    {write = 1; move = 1; next_state = state_b},
    {write = 0; move = -1; next_state = state_f}
  )
and state_b = State (
    {write = 0; move = 1; next_state = state_c},
    {write = 0; move = 1; next_state = state_d}
  )
and state_c = State (
    {write = 1; move = -1; next_state = state_d},
    {write = 1; move = 1; next_state = state_e}
  )
and state_d = State (
    {write = 0; move = -1; next_state = state_e},
    {write = 0; move = -1; next_state = state_d}
  )
and state_e = State (
    {write = 0; move = 1; next_state = state_a},
    {write = 1; move = 1; next_state = state_c}
  )
and state_f = State (
    {write = 1; move = -1; next_state = state_a},
    {write = 1; move = 1; next_state = state_a}
  )

let initial_machine = {
  tape = Map.empty (module Int);
  cursor = 0;
  state = state_a;
}

let run n =
  let rec f n machine =
    if n = 0 then machine
    else f (n - 1) (run_state machine)
  in
  f n initial_machine

let checksum {tape} = Map.count tape ~f:((=) 1)

let () =
  run 12794428
  |> checksum
  |> Stdio.printf "%d\n"
