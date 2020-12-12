open Memtrace_filter

let print_alloc alloc_time index_size irmin_size =
  let alloc_time = Timedelta.to_int64 alloc_time in
  Printf.printf
    "timestamp=%f index=%fG irmin=%fG\n"
    (Int64.to_float alloc_time /. 1_000_000.)
    (Stat.gb index_size)
    (Stat.gb irmin_size)

let irmin_package_name = Str.regexp "Irmin.*"
let index_package_name = Str.regexp "Index.*"

let is_irmin = is_package_name irmin_package_name
let is_index = is_package_name index_package_name

let () =
  let trace = Reader.open_ ~filename:Sys.argv.(1) in
  let index_size = Stat.init () in
  let irmin_size = Stat.init () in
  Reader.iter trace (fun time ev ->
      match ev with
      | Alloc alloc ->
        let size = nbytes ~trace alloc.nsamples in
        if is_index trace alloc.backtrace_buffer then begin
          Stat.add index_size alloc.obj_id size;
          print_alloc time index_size irmin_size
        end else if is_irmin trace alloc.backtrace_buffer then begin
          Stat.add irmin_size alloc.obj_id size;
          print_alloc time index_size irmin_size
        end
      | Collect id ->
        Stat.remove index_size id;
        Stat.remove irmin_size id
      | _ -> ());
  Reader.close trace
  ;
