(* This file is part of Learn-OCaml.
 *
 * Copyright (C) 2019 OCaml Software Foundation.
 * Copyright (C) 2016-2018 OCamlPro.
 *
 * Learn-OCaml is distributed under the terms of the MIT license. See the
 * included LICENSE file for details. *)


let (>>=) = Lwt.(>>=)


let read_file file =
  let open Lwt.Infix in
  let clear_input ls =
    List.fold_right (fun l acc ->
      if l = "" or l = "\n" then acc
      else l::acc
    ) ls []
  in
  let parse_content = function
    | "" ->
        Lwt.return []
    | content ->
        String.split_on_char '\n' content |> clear_input |> Lwt.return
  in
  Lwt_io.with_file ~mode:Lwt_io.Input file Lwt_io.read  >>=
    parse_content


let find_libs libs =
  let find_lib lib =
    let path =
      try
        Lwt.return (Findlib.package_directory lib)
      with _ -> Lwt.fail_with ("Can't find lib " ^ lib ^ "in path.")
    in
    path >>=
      (fun path ->
        Lwt.return (Format.sprintf "%s/%s.cma" path lib ))
  in
  List.fold_left (
    fun ls l ->
      ls >>= (fun ls ->
        find_lib l >>= (fun l ->
          Lwt.return (l::ls)
        )
    )
  ) (Lwt.return []) libs >>=
  (fun libs -> Lwt.return (List.rev libs))


let call_jsoo out_dir libs =
  let cmd = "js_of_ocaml" in
  let out_file = Filename.concat out_dir "extra.js" in
  let args =
    cmd :: libs @ ("-o"::[out_file]) |> Array.of_list
  in
  Lwt_process.exec (cmd, args) >>=
    function
    | Unix.WEXITED 0 ->
        Lwt.return ()
    | _ ->
        Lwt.fail_with ("js_of_ocaml failed to build " ^ out_file ^ ".")


let build
  ?(in_dir="./exercises/")
  ?(out_dir="www/js/")
  file =
    let file_path = Filename.concat in_dir file in
    read_file file_path >>=
    (fun libs -> find_libs libs) >>=
    (fun libs -> call_jsoo out_dir libs)
