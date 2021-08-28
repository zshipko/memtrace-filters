open Memtrace_filter

let print_alloc alloc_time total_size =
  let alloc_time = Timedelta.to_int64 alloc_time in
  Printf.printf "timestamp=%f total=%fG\n"
    (Int64.to_float alloc_time /. 1_000_000.)
    (Stat.gb total_size)

let () =
  let trace = Reader.open_ ~filename:Sys.argv.(1) in
  let total_size = Stat.init trace in
  Reader.iter trace (fun time ev ->
      match ev with
      | Alloc alloc ->
          Stat.add total_size alloc.obj_id alloc.nsamples;
          print_alloc time total_size
      | Collect id -> Stat.remove total_size id
      | _ -> ());
  Reader.close trace
