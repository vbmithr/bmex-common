open Async
module DTC = Dtc_pb.Dtcprotocol_piqi

val addr_of_uri :
  Uri.t -> Conduit_async.V2.addr Deferred.t
(** [addr_of_uri uri] resolves [uri] and returns a value suitable for
    use with [Conduit_async.V2]. *)

val write_message :
  Writer.t -> DTC.dtcmessage_type -> ('a -> Piqirun.OBuf.t) -> 'a -> unit
