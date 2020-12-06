open Lwt.Infix
module StringMap = Map.Make(String)

module Main (TIME: Mirage_time.S) (PClock: Mirage_clock.PCLOCK) (RES: Resolver_lwt.S) (CON: Conduit_mirage.S) = struct

  module C = Control.Make (TIME) (PClock)

  let functionality store = 
    let tstr = C.time () in
    Logs.info (fun m -> m "functionality-TS: %s" tstr);
    let rec loop = function
      | 200 -> Lwt.return Control.Status.Terminate
      | n ->
        let tstr = C.time () in
        if n = 0 
        then
          Logs.info (fun m -> m "%s: HELLO... (%i)" tstr n)
        else
          Logs.info (fun m -> m "%s: AGAIN (%i)" tstr n);
        store#set "count" (Store.VInt (n+1));
        TIME.sleep_ns (Duration.of_sec 1) >>= fun () ->
        loop (Store.to_int (store#get "count" (Store.VInt 0))) 
    in
    loop (Store.to_int (store#get "count" (Store.VInt 0)))

  let start _time _pclock resolver conduit =
    let tstr = C.time () in
    Logs.info (fun m -> m "start-TS: %s" tstr);
    let token = Key_gen.token () in
    let repo = Key_gen.repo () in
    let migration = Key_gen.migration () in
    let id = Key_gen.id () in
    let host_id = Key_gen.hostid () in
    let store = new Store.webStore conduit resolver repo token id host_id in
    store#init (C.time) migration (C.steady) >>= fun _ ->
    let l = C.main_loop () in
    let f = functionality store in
    Lwt.pick [l;f] >>= fun status -> match status with  
      | Control.Status.Suspend -> begin 
        store#suspend (C.time) status
      end
      | Control.Status.Migrate -> begin 
        store#suspend (C.time) status 
      end
      | _ -> store#terminate
end
