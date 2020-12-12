open Memtrace.Trace

module Stat = struct
  type t = {
    mutable b: float;
    ids: (Obj_id.t, float) Hashtbl.t
  }

  let init () = {b = 0.; ids = Hashtbl.create 8}

  let add t id x =
    t.b <- t.b +. x;
    Hashtbl.replace t.ids id x

  let remove t id =
    match Hashtbl.find_opt t.ids id with
    | Some x ->
      Hashtbl.remove t.ids id;
      t.b <- t.b -. x
    | None -> ()

  let gb t =
    t.b /. 1024. /. 1024. /. 1024.
end

let print_alloc alloc_time index_size irmin_size =
  let alloc_time = Timedelta.to_int64 alloc_time in
  Printf.printf
    "timestamp=%f index=%fG irmin=%fG\n"
    (Int64.to_float alloc_time /. 1_000_000.)
    (Stat.gb index_size)
    (Stat.gb irmin_size)

let irmin_package_name = Str.regexp "Irmin.*"
let index_package_name = Str.regexp "Index.*"

let nbytes ~trace nsamples =
  let { Info.sample_rate; word_size; _ } = Reader.info trace in
  let nwords = Float.of_int nsamples /. sample_rate in
  nwords *. Float.of_int word_size /. 4.

let is_package_name name trace alloc =
  let i = ref 0 in
  Array.exists (fun loc ->
      if !i >= Array.length alloc then
        false
      else
        let exists = List.exists (fun loc ->
            Str.string_match name loc.Location.defname 0
          ) (Reader.lookup_location_code trace loc) in
        incr i;
        exists
    ) alloc

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
