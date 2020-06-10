(* This file is part of Learn-OCaml.
 *
 * Copyright (C) 2019 OCaml Software Foundation.
 * Copyright (C) 2016-2018 OCamlPro.
 *
 * Learn-OCaml is distributed under the terms of the MIT license. See the
 * included LICENSE file for details. *)


(** [build ~out_dir ~in_dir filename] writes an extra_lib.js file in
    in [out_dir] that contains all the libraries referenced in
    [in_dir]/[filename].

    By default the [out_dir] is /www/js and the[in_dir] is /exercices.
*)
val build :
  ?in_dir:string -> ?out_dir:string -> string -> unit Lwt.t

