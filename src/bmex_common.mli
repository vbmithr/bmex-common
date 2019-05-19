open Core
open Async

module DTC = Dtc_pb.Dtcprotocol_piqi

val span_of_interval :
  DTC.historical_data_interval_enum -> Time_ns.Span.t

val write_message :
  Writer.t -> DTC.dtcmessage_type -> ('a -> Piqirun.OBuf.t) -> 'a -> unit
