include Memtrace.Trace

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



let nbytes ~trace nsamples =
  let { Info.sample_rate; word_size; _ } = Reader.info trace in
  let nwords = Float.of_int nsamples /. sample_rate in
  nwords *. Float.of_int word_size /. 4.

let is_package_name name trace alloc =
  Array.exists (fun loc ->
      let locs = Reader.lookup_location_code trace loc in
      List.exists (fun loc ->
          Str.string_match name loc.Location.defname 0
        ) locs
    ) alloc

