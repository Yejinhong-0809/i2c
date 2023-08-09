`ifndef RKV_USER_WAIT_DETECT_ABORT_SOURCE_SEQ_SV
`define RKV_USER_WAIT_DETECT_ABORT_SOURCE_SEQ_SV
import uvm_pkg::*;
class rkv_user_wait_detect_abort_source_seq extends rkv_i2c_pkg::rkv_apb_base_sequence;
   bit[16:0]  abort_source_intr;
  
  `uvm_object_utils(rkv_user_wait_detect_abort_source_seq)
  
  function new(string name = "rkv_user_wait_detect_abort_source_seq");
     super.new(name);
  endfunction
  
/*  task body();
    `uvm_info("body", "Entering...", UVM_HIGH)
    super.body();
    
   while(1) begin
    rgm.IC_TX_ABRT_SOURCE.mirror(status);
    abort_source_intr = rgm.IC_TX_ABRT_SOURCE.get();
    foreach(abort_source_intr[i]) begin
      if(abort_source_intr[i] == 1)  begin 
        `uvm_info("abort_source_intr",$sformatf("abort_source_intr[%d] is arisen", i), UVM_HIGH) 
        break;
      end
     end
    end
  endtask
 */
  
  task body();
    `uvm_info("body", "Entering...", UVM_HIGH)
    super.body();
    
    while(1) begin
      rgm.IC_RAW_INTR_STAT.mirror(status);
      if(rgm.IC_RAW_INTR_STAT.TX_ABRT.get() == 1)  break;
      repeat(100) @(p_sequencer.vif.cb_mon);
    end
    
    rgm.IC_TX_ABRT_SOURCE.mirror(status);
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_7B_ADDR_NOACK.get() == 1)   `uvm_info(get_type_name, "TX ABORT because of ABRT_7B_ADDR_NOACK", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_10ADDR1_NOACK.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_10ADDR1_NOACK", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_10ADDR2_NOACK.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_10ADDR2_NOACK", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_TXDATA_NOACK.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_TXDATA_NOACK", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_GCALL_NOACK.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_GCALL_NOACK", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_GCALL_READ.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_GCALL_READ", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_HS_ACKDET.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_HS_ACKDET", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_SBYTE_ACKDET.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_SBYTE_ACKDET", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_HS_NORSTRT.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_HS_NORSTRT", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_SBYTE_NORSTRT.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_SBYTE_NORSTRT", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_10B_RD_NORSTRT.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_10B_RD_NORSTRT", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_MASTER_DIS.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_MASTER_DIS", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ARB_LOST.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ARB_LOST", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_SLVFLUSH_TXFIFO.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_SLVFLUSH_TXFIFO", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_SLV_ARBLOST.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_SLV_ARBLOST", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_SLVRD_INTX.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_SLVRD_INTX", UVM_LOW)
    if(rgm.IC_TX_ABRT_SOURCE.ABRT_USER_ABRT.get() == 1) `uvm_info(get_type_name(), "TX ABORT because of ABRT_USER_ABRT", UVM_LOW)    
    `uvm_info("body", "Exiting...", UVM_HIGH)   
  endtask
endclass
`endif
