open Async
open Pbrt
open Dtc_pb.Dtcprotocol_types

val write_message :
  Writer.t -> dtcmessage_type -> ('a -> Encoder.t -> unit) -> 'a -> unit
