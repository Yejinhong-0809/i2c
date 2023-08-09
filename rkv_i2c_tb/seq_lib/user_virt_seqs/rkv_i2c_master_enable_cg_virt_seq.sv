`ifndef RKV_I2C_MASTER_ENABLE_CG_VIRT_SEQ_SV
`define RKV_I2C_MASTER_ENABLE_CG_VIRT_SEQ_SV

class rkv_i2c_master_enable_cg_virt_seq extends rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  rkv_apb_noread_packet_seq   apb_noread_packet_seq;
  `uvm_object_utils(rkv_i2c_master_enable_cg_virt_seq)
  
  function new(string name = "rkv_i2c_master_enable_cg_virt_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);
    
    //part 1: disenable then write
    `uvm_do_on_with( apb_user_config_seq, 
                     p_sequencer.apb_mst_sqr, 
                    {
                        SPEED == 2;
                        IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                        IC_10BITADDR_MASTER == 0;
                        IC_FS_SCL_HCNT == 200;
                        IC_FS_SCL_LCNT == 200;
                        IC_RESTART_EN == 1;
                        TX_EMPTY_CTRL == 0;
                        ENABLE == 0;
                    })
    
    `uvm_do_on_with( apb_write_packet_seq, p_sequencer.apb_mst_sqr, 
                    { 
                      packet.size() == 1;
                      packet[0] == 'b1111_0001;
                    })
    rgm.IC_STATUS.mirror(status);   //the data can not write into tx_fifo without enabling the dut
    `uvm_info(get_type_name(), "part 1 finished", UVM_HIGH)
    
    
    //part 2   
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);
    rgm.IC_ENABLE_STATUS.mirror(status);
    
    `uvm_do_on_with( apb_write_packet_seq, p_sequencer.apb_mst_sqr, 
                    { 
                      packet.size() == 2;
                      packet[0] == 'b1111_0001;
                      packet[1] == 'b1111_0010;
                    })
      
    rgm.IC_STATUS.mirror(status);
    rgm.IC_ENABLE.ENABLE.set(0);  //if disenable the register of IC_ENABLE, it will clear tx_fifo and rx_fifo
    rgm.IC_ENABLE.update(status);
    rgm.IC_ENABLE_STATUS.mirror(status);
    rgm.IC_STATUS.mirror(status);
    
/*    `uvm_do_on_with( i2c_slv_write_resp_seq, 
                     p_sequencer.i2c_slv_sqr, 
                    {
                        nack_addr == 0;
                        nack_data == 0;
                        nack_addr_count == 0;
                    })
*/      //it will make the simulation that it can not stop

    //part 3  disable then read
    `uvm_do_on_with(apb_noread_packet_seq, p_sequencer.apb_mst_sqr, { packet.size() == 1; })    
    #10us;
    rgm.IC_STATUS.mirror(status);
    `uvm_info(get_type_name(), "part 2 finished", UVM_HIGH)
   
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);
    //part 4 read data but disenable before the data send to the rx_fifo through I2C 
    fork
      `uvm_do_on_with(apb_noread_packet_seq,p_sequencer.apb_mst_sqr,{ packet.size() == 3; })
    //warning: because don't add soft to packet.size() so the simulation can't run over!!!!!
      `uvm_do_on_with( i2c_slv_read_resp_seq, 
                       p_sequencer.i2c_slv_sqr,
                      { packet.size() == 1;
                        packet[0] == 8'b00001111;
                       })
    join_none
    
    while(1) begin
      rgm.IC_STATUS.mirror(status);
      if(rgm.IC_STATUS.RFNE.get() == 1) begin
      rgm.IC_ENABLE.ENABLE.set(0);
      rgm.IC_ENABLE.update(status);        
      rgm.IC_STATUS.mirror(status);  
      break;
      end
      //else  repeat(100)  @(vif.cb_mon);   it can improve your simulation speed
    end

    #1us;  //in order to easy to observe the waveform, in fact you can set it depending on you
    //after disable change to write
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);    
    #10us;  //in order to wait the other two read operations finished ,it will be easy to observe the waveform
    fork
      //Combined transmission format: read then write so in need to send start signal and address repeatedly 
      `uvm_do_on_with(apb_write_packet_seq, 
                      p_sequencer.apb_mst_sqr,
                      {packet.size() == 1;
                      packet[0] == 8'b11110001;
                       })
     `uvm_do_on(i2c_slv_write_resp_seq,p_sequencer.i2c_slv_sqr)   
    join_any
  //  rgm.IC_STATUS.mirror(status);
  //  `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)  //can use the code blow

    while(1) begin
    rgm.IC_STATUS.mirror(status);
    if(rgm.IC_STATUS.ACTIVITY.get() == 0 && rgm.IC_STATUS.TFE.get() == 1) break;
    repeat(100)  @(vif.cb_mon);
    end  
 
    
  /*
   Contains a while(1) loop, which has continuous reading IC_STATUS,because I have modified apb_wait_empty_seq
   if(rgm.IC_STATUS.ACTIVITY.get() == 0 && rgm.IC_STATUS.TFE.get() == 1 && rgm.IC_STATUS.RFNE.get() == 0) break;
   so rx_fifo data can not clear so simulation can not stop
   */
  
    #10us;
/*
    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);    
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);
    rgm.IC_DATA_CMD.mirror(status);
    `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, {intr_id == IC_RX_UNDER_INTR_ID;})
    if(vif.intr[IC_RX_UNDER_INTR_ID] == 1)
      `uvm_info(get_type_name(), "RX_UNDER interrupt is rise", UVM_HIGH)       
*/
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
    
  endtask
  
endclass
`endif
