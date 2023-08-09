`ifndef RKV_I2C_MASTER_SDA_CONTROL_VIRT_SEQ_SV
`define RKV_I2C_MASTER_SDA_CONTROL_VIRT_SEQ_SV

class rkv_i2c_master_sda_control_virt_seq extends rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  bit [7:0]  time_set [] = '{8'd1, 8'd50, 8'd150};  //Observe the waveform but no find any differences???
  `uvm_object_utils(rkv_i2c_master_sda_control_virt_seq)
  
  function new(string name = "rkv_i2c_master_sda_control_virt_seq");
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
                    } )
      
    foreach(time_set[i]) begin
      rgm.IC_SDA_HOLD.mirror(status);
      rgm.IC_SDA_HOLD.IC_SDA_RX_HOLD.set(time_set[i]);
      rgm.IC_SDA_HOLD.update(status);
      
      rgm.IC_ENABLE.ENABLE.set(1);
      rgm.IC_ENABLE.update(status);
      
      fork
        `uvm_do_on_with(  apb_read_packet_seq, 
                          p_sequencer.apb_mst_sqr, 
                        { 
                          packet.size() == 1;
                        })
        
        `uvm_do_on_with(  i2c_slv_read_resp_seq, 
                          p_sequencer.i2c_slv_sqr, 
                        {
                          packet.size() == 1;
                          packet[0] == 8'b0101_0101;
                          })
      join

      rgm.IC_ENABLE.ENABLE.set(0);
      rgm.IC_ENABLE.update(status);
    end

    foreach(time_set[i]) begin
      rgm.IC_SDA_HOLD.mirror(status);
      rgm.IC_SDA_HOLD.IC_SDA_TX_HOLD.set(time_set[i]);
      rgm.IC_SDA_HOLD.update(status);
      
      rgm.IC_ENABLE.ENABLE.set(1);
      rgm.IC_ENABLE.update(status);
      
      fork
        `uvm_do_on_with(  apb_write_packet_seq, 
                          p_sequencer.apb_mst_sqr, 
                        { 
                          packet.size() == 1;
                          packet[0] == 8'b0101_0101;
                        })
        
        `uvm_do_on_with(  i2c_slv_write_resp_seq, 
                          p_sequencer.i2c_slv_sqr, 
                        {
                          nack_addr == 0;
                          nack_data == 0;
                          nack_addr_count == 0;
                          })
      join

      rgm.IC_ENABLE.ENABLE.set(0);
      rgm.IC_ENABLE.update(status);
    end
    
    rgm.IC_SDA_SETUP.mirror(status);
    rgm.IC_SDA_SETUP.SDA_SETUP.set(10);  //Observe the waveform and find no interruption because DUT is at master mode
    rgm.IC_SDA_SETUP.update(status);     //no effect
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);
    #10us;
    
    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_SDA_SETUP.SDA_SETUP.set(5);  
    rgm.IC_SDA_SETUP.update(status);  
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);
    #10us;
    
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  endtask
endclass       

`endif