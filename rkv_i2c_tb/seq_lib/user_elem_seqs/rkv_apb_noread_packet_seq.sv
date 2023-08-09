`ifndef RKV_APB_NOREAD_PACKET_SEQ_SV
`define RKV_APB_NOREAD_PACKET_SEQ_SV

class rkv_apb_noread_packet_seq extends rkv_apb_base_sequence;
  //rand bit [7:0] packet [];
  `uvm_object_utils(rkv_apb_noread_packet_seq)
  constraint cstr{
    soft packet.size() == 1;  //must add soft!!
  }
  
  function new(string name = "rkv_apb_noread_packet_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("body", "Entering...", UVM_HIGH)
    super.body();    
    
    foreach(packet[i]) begin
      rgm.IC_DATA_CMD.CMD.set(RGM_READ);
      rgm.IC_DATA_CMD.DAT.set(0);
      rgm.IC_DATA_CMD.write(status, 9'b100000000);
    end
  endtask
endclass

`endif