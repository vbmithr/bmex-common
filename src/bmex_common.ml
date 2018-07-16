open Core
open Async

module DTC = Dtc_pb.Dtcprotocol_piqi

let addr_of_uri uri : Conduit_async.V2.addr Deferred.t =
  let host, service =
  match Uri.host uri, Uri.port uri, Uri_services.tcp_port_of_uri uri with
  | Some h, Some p, _ -> h, string_of_int p
  | Some h, None, Some p -> h, string_of_int p
  | Some h, None, None -> h, ""
  | _ -> invalid_arg "async_of_uri: no host in URL" in
  Unix.Addr_info.get ~host ~service [] >>| function
  | [] -> failwith "getaddrinfo: unable to resolve"
  | { ai_family; ai_socktype; ai_protocol; ai_addr; ai_canonname } :: _ ->
    match Uri.scheme uri, ai_addr with
    | _, ADDR_UNIX path -> `Unix_domain_socket path
    | Some "https", ADDR_INET (h, p)
    | Some "wss", ADDR_INET (h, p) ->
      let h = Ipaddr_unix.of_inet_addr h in
      `OpenSSL (h, p, Conduit_async.V2.Ssl.Config.create ())
    | _, ADDR_INET (h, p) ->
      let h = Ipaddr_unix.of_inet_addr h in
      `TCP (h, p)

let write_message w (typ : DTC.dtcmessage_type) gen msg =
  let typ =
    Piqirun.(DTC.gen_dtcmessage_type typ |> to_string |> init_from_string |> int_of_varint) in
  let msg = (gen msg |> Piqirun.to_string) in
  let header = Bytes.create 4 in
  Binary_packing.pack_unsigned_16_little_endian ~buf:header ~pos:0 (4 + String.length msg) ;
  Binary_packing.pack_unsigned_16_little_endian ~buf:header ~pos:2 typ ;
  Writer.write_bytes w header ;
  Writer.write w msg
