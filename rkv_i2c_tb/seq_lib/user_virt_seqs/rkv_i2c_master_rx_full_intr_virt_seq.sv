`ifndef   RKV_I2C_MASTER_RX_FULL_INTR_VIRT_SEQ_SV
`define   RKV_I2C_MASTER_RX_FULL_INTR_VIRT_SEQ_SV

class rkv_i2c_master_rx_full_intr_virt_seq extends rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  rkv_apb_noread_packet_seq   apb_noread_packet_seq;
  
  `uvm_object_utils(rkv_i2c_master_rx_full_intr_virt_seq)
  
  function new(string name = "rkv_i2c_master_rx_full_intr_virt_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10); 
    
    rgm.IC_RX_TL.RX_TL.set(3);
    rgm.IC_RX_TL.update(status);
    `uvm_do_on_with(  apb_user_config_seq, 
                      p_sequencer.apb_mst_sqr, 
                    {
                      SPEED == 2;       
                      IC_10BITADDR_MASTER == 0;
                      IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                      IC_FS_SCL_HCNT == 200;
                      IC_FS_SCL_LCNT == 200;
                      IC_RESTART_EN == 1;  
                      TX_EMPTY_CTRL == 0;
                      ENABLE == 1;
                    } ) 
/*     
    fork
      `uvm_do_on_with(  i2c_slv_read_resp_seq, 
                        p_sequencer.i2c_slv_sqr,
                      {
                        packet.size() == 8;
                        packet[0] == 8'b1000_0000;
                        packet[1] == 8'b1000_0001;
                        packet[2] == 8'b1000_0010;
                        packet[3] == 8'b1000_0011;
                        packet[4] == 8'b1000_0100;
                        packet[5] == 8'b1000_0101;
                        packet[6] == 8'b1000_0110;
                        packet[7] == 8'b1000_0111;
                      })
    join_none
    
    `uvm_do_on_with(apb_noread_packet_seq, p_sequencer.apb_mst_sqr, { packet.size() == 8;} )
    `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_RX_FULL_INTR_ID; })
    if(vif.intr[IC_RX_FULL_INTR_ID] != 1)   
      `uvm_error("Error", "IC_RX_FULL interrupt is not high")
    else begin
      #10us;
      `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
    end
*/

    fork
      `uvm_do_on_with(apb_noread_packet_seq,p_sequencer.apb_mst_sqr,{packet.size() == 8;})
      `uvm_do_on_with(i2c_slv_read_resp_seq, 
                      p_sequencer.i2c_slv_sqr,
                      {packet.size() == 8;
                       packet[0] == 8'b00001111;
                       packet[1] == 8'b00000001;
                       packet[2] == 8'b00000010;
                       packet[3] == 8'b00000011;
                       packet[4] == 8'b00000100;
                       packet[5] == 8'b00000101;
                       packet[6] == 8'b00000110;
                       packet[7] == 8'b00000111;
                       })
    join
    
    fork 
      rgm.IC_STATUS.mirror(status);
      repeat (8) rgm.IC_DATA_CMD.mirror(status);  //read date from rx_fifo to IC_DATE_CMD(dut),then to IC_DATA_CMD(software)
    join_none

    `uvm_do_on_with(apb_intr_wait_seq,
                    p_sequencer.apb_mst_sqr,
                   {intr_id == IC_RX_FULL_INTR_ID;
                   })
  
    // check if interrupt output is same as interrupt status field
    if(vif.get_intr(IC_RX_FULL_INTR_ID) !== 1'b1) begin
      `uvm_error("INTRERR", "interrupt output IC_RX_FULL_INTR_ID is not high")
    end
    else begin
      repeat(100) @(p_sequencer.vif.i2c_clk);
      `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)  
    end

  endtask
endclass

`endif
