`ifndef RKV_APB_WRITE_NOCHECK_PACKET_SEQ_SV
`define RKV_APB_WRITE_NOCHECK_PACKET_SEQ_SV

class rkv_apb_write_nocheck_packet_seq extends rkv_apb_base_sequence;
  `uvm_object_utils(rkv_apb_write_nocheck_packet_seq)
  constraint cstr{
    soft packet.size() == 1;
  }
  
  function new(string name = "rkv_apb_write_nocheck_packet_seq");
    super.new(name);
  endfunction
  
  task body();
    super.body();
    foreach(packet[i]) begin
      rgm.IC_DATA_CMD.CMD.set(0);
      rgm.IC_DATA_CMD.DAT.set(packet[i]);
      rgm.IC_DATA_CMD.update(status);
    end
  endtask
endclass
    
`endif
