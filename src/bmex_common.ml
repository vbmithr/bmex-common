open Core
open Async

module DTC = Dtc_pb.Dtcprotocol_piqi

let span_of_interval :
  DTC.historical_data_interval_enum -> Time_ns.Span.t = function
  | `interval_1_week -> Time_ns.Span.of_day 7.
  | `interval_1_day -> Time_ns.Span.of_day 1.
  | `interval_2_hours -> Time_ns.Span.of_int_sec (120 * 60)
  | `interval_1_hour -> Time_ns.Span.of_int_sec (60 * 60)
  | `interval_30_minute -> Time_ns.Span.of_int_sec (30 * 60)
  | `interval_15_minute -> Time_ns.Span.of_int_sec (15 * 60)
  | `interval_10_minute -> Time_ns.Span.of_int_sec (10 * 60)
  | `interval_5_minute -> Time_ns.Span.of_int_sec (5 * 60)
  | `interval_1_minute -> Time_ns.Span.of_int_sec 60
  | `interval_30_seconds -> Time_ns.Span.of_int_sec 30
  | `interval_10_seconds -> Time_ns.Span.of_int_sec 10
  | `interval_5_seconds -> Time_ns.Span.of_int_sec 5
  | `interval_4_seconds -> Time_ns.Span.of_int_sec 4
  | `interval_2_seconds -> Time_ns.Span.of_int_sec 2
  | `interval_1_second -> Time_ns.Span.of_int_sec 1
  | `interval_tick -> Time_ns.Span.zero

let write_message w (typ : DTC.dtcmessage_type) gen msg =
  let typ =
    Piqirun.(DTC.gen_dtcmessage_type typ |> to_string |> init_from_string |> int_of_varint) in
  let msg = (gen msg |> Piqirun.to_string) in
  let header = Bytes.create 4 in
  Binary_packing.pack_unsigned_16_little_endian ~buf:header ~pos:0 (4 + String.length msg) ;
  Binary_packing.pack_unsigned_16_little_endian ~buf:header ~pos:2 typ ;
  Writer.write_bytes w header ;
  Writer.write w msg
