`ifndef   RKV_I2C_MASTER_RX_OVER_INTR_VIRT_SEQ_SV
`define   RKV_I2C_MASTER_RX_OVER_INTR_VIRT_SEQ_SV

class rkv_i2c_master_rx_over_intr_virt_seq extends rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  rkv_apb_noread_packet_seq   apb_noread_packet_seq;
  
  `uvm_object_utils(rkv_i2c_master_rx_over_intr_virt_seq)
  
  function new(string name = "rkv_i2c_master_rx_over_intr_virt_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);
    
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
    
    fork
      `uvm_do_on_with(apb_noread_packet_seq, p_sequencer.apb_mst_sqr, {packet.size() == 8;})
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
                        //packet[8] == 8'b1000_1000;
    //can't set packet.size() > the depth of fifo, otherwise it can't produce rx_over_interrupt signal because the date can't
    //write into fifo
                      })
    join
    rgm.IC_STATUS.mirror(status);
    
    fork
      `uvm_do_on_with(apb_noread_packet_seq, p_sequencer.apb_mst_sqr, {packet.size() == 1;})
      `uvm_do_on_with(  i2c_slv_read_resp_seq, 
                        p_sequencer.i2c_slv_sqr,
                      {      
                        packet.size() == 8;
                        packet[0] == 8'b1000_0111;
                      })
    join_none
    
    `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, {intr_id == IC_RX_OVER_INTR_ID; })
    if(vif.intr[IC_RX_OVER_INTR_ID] == 1)  
      `uvm_do_on_with(apb_intr_clear_seq, p_sequencer.apb_mst_sqr,{ intr_id == IC_RX_OVER_INTR_ID; });
    
    rgm.IC_RAW_INTR_STAT.mirror(status);
    if(vif.intr[IC_RX_OVER_INTR_ID] == 0) 
      `uvm_info(get_type_name(), "IC_RX_OVER interrupt has been cleard", UVM_HIGH)      
    #10us;

/*
    fork
      `uvm_do_on_with(apb_noread_packet_seq, p_sequencer.apb_mst_sqr, {packet.size() == 8;})
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
    join  
    
    rgm.IC_STATUS.mirror(status);
    rgm.IC_DATA_CMD.mirror(status);  
    
    fork
      `uvm_do_on_with(apb_noread_packet_seq,p_sequencer.apb_mst_sqr,{packet.size() == 2;})
      `uvm_do_on_with(i2c_slv_read_resp_seq, 
                      p_sequencer.i2c_slv_sqr,
                      {packet.size() == 2;
                      packet[0] == 8'b0000_1000;
                      packet[1] == 8'b0000_1001;
                     })
      tx_abrt_check();
    join_none   
    
    `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, {intr_id == IC_RX_OVER_INTR_ID; })
    if(vif.get_intr(IC_RX_OVER_INTR_ID) == 1)
      `uvm_info(get_type_name(), "IC_RX_OVER interrupt has been cleard", UVM_HIGH)
    #10us;
  endtask
*/
/*
  task tx_abrt_check();
    while(1) begin
      rgm.IC_TX_ABRT_SOURCE.mirror(status);
      @(posedge vif.i2c_clk)
      if(vif.intr[3] == 1) begin
        rgm.IC_TX_ABRT_SOURCE.mirror(status); 
        break;
      end
    end
  endtask    
*/  
  endtask
endclass
    
    

`endif
