open Memtrace_filter

let print_alloc alloc_time index_size irmin_size total_size =
  let alloc_time = Timedelta.to_int64 alloc_time in
  Printf.printf "timestamp=%f index=%fG irmin=%fG total=%fG\n"
    (Int64.to_float alloc_time /. 1_000_000.)
    (Stat.gb index_size) (Stat.gb irmin_size) (Stat.gb total_size)

let is_irmin = matches_package_name @@ Str.regexp "Irmin.*"

let is_index trace alloc alloc_len =
  let exception Return of bool in
  try
    for i = 0 to alloc_len - 1 do
      let locs = Reader.lookup_location_code trace alloc.(i) in
      List.iteri
        (fun i loc ->
          let is_index_unix_raw =
            Str.string_match
              (Str.regexp "Index_unix__Raw.*")
              loc.Location.defname 0
          in
          let is_actually_irmin_pack_io =
            i > 0
            && Str.string_match
                 (Str.regexp "Irmin_pack__IO.*")
                 (List.nth locs (i - 1)).defname 0
          in
          if is_index_unix_raw && is_actually_irmin_pack_io then
            raise (Return false)
          else if Str.string_match (Str.regexp "Index.*") loc.defname 0 then
            raise (Return true))
        locs
    done;
    false
  with Return x -> x

let () =
  let trace = Reader.open_ ~filename:Sys.argv.(1) in
  let index_size = Stat.init trace in
  let irmin_size = Stat.init trace in
  let total_size = Stat.init trace in
  Reader.iter trace (fun time ev ->
      match ev with
      | Alloc alloc ->
          Stat.add total_size alloc.obj_id alloc.nsamples;
          if is_index trace alloc.backtrace_buffer alloc.backtrace_length then (
            Stat.add index_size alloc.obj_id alloc.nsamples;
            print_alloc time index_size irmin_size total_size)
          else if is_irmin trace alloc.backtrace_buffer alloc.backtrace_length
          then (
            Stat.add irmin_size alloc.obj_id alloc.nsamples;
            print_alloc time index_size irmin_size total_size)
      | Collect id ->
          Stat.remove total_size id;
          Stat.remove index_size id;
          Stat.remove irmin_size id
      | _ -> ());
  Reader.close trace
