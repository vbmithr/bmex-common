open Async
module DTC = Dtc_pb.Dtcprotocol_piqi

val write_message :
  Writer.t -> DTC.dtcmessage_type -> ('a -> Piqirun.OBuf.t) -> 'a -> unit
