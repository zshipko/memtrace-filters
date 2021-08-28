include Memtrace.Trace

let nbytes ~trace nsamples =
  let { Info.word_size; sample_rate; _ } = Reader.info trace in
  let nwords = Float.of_int nsamples /. sample_rate in
  nwords *. Float.of_int (word_size / 8)

module Stat = struct
  type t = {
    trace : Reader.t;
    mutable samples : int;
    ids : (Obj_id.t, int) Hashtbl.t;
  }

  let init trace = { trace; samples = 0; ids = Hashtbl.create 8 }

  let add t id x =
    t.samples <- t.samples + x;
    Hashtbl.replace t.ids id x

  let remove t id =
    match Hashtbl.find_opt t.ids id with
    | Some x ->
        Hashtbl.remove t.ids id;
        t.samples <- t.samples - x
    | None -> ()

  let gb t = nbytes ~trace:t.trace t.samples /. 1024. /. 1024. /. 1024.
end

let matches_package_name name trace alloc nalloc =
  Array.exists
    (fun loc ->
      let locs = Reader.lookup_location_code trace loc in
      List.exists (fun loc -> Str.string_match name loc.Location.defname 0) locs)
    (Array.sub alloc 0 nalloc)

let print_backtrace trace alloc nalloc =
  for i = 0 to nalloc - 1 do
    let locs = Reader.lookup_location_code trace alloc.(i) in
    List.iter
      (fun loc ->
        output_string stderr (Location.to_string loc);
        output_string stderr "\n")
      locs;
    flush stderr
  done
