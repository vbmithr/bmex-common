open Core
open Async
open Pbrt
module DTCPb = Dtc_pb.Dtcprotocol_pb

let write_message w typ gen msg =
  let e = Encoder.create () in
  DTCPb.encode_dtcmessage_type typ e ;
  let typ = Decoder.(of_bytes (Encoder.to_bytes e) |> int_as_varint) in
  let msg = Encoder.(let e = create () in gen msg e ; to_bytes e) in
  let header = Bytes.create 4 in
  Binary_packing.pack_unsigned_16_little_endian ~buf:header ~pos:0 (4 + Bytes.length msg) ;
  Binary_packing.pack_unsigned_16_little_endian ~buf:header ~pos:2 typ ;
  Writer.write_bytes w header ;
  Writer.write_bytes w msg
