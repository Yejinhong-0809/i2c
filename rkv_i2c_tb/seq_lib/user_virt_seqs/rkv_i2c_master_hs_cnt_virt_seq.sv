`ifndef RKV_I2C_MASTER_HS_CNT_VIRT_SEQ_SV
`define RKV_I2C_MASTER_HS_CNT_VIRT_SEQ_SV

class rkv_i2c_master_hs_cnt_virt_seq extends rkv_i2c_base_virtual_sequence; 
  rkv_apb_user_config_seq   apb_user_config_seq;
  `uvm_object_utils(rkv_i2c_master_hs_cnt_virt_seq)
  
  function new(string name = "rkv_i2c_master_hs_cnt_virt_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);    
  
    cfg.i2c_cfg.slave_cfg[0].bus_speed = lvc_i2c_pkg::HIGHSPEED_MODE;   //bus_speed default value is STANDARD_MODE
    //bus_speed_enum comes from lvc_i2c_types.sv  
    env.i2c_slv.reconfigure_via_task(cfg.i2c_cfg.slave_cfg[0]);  
    /*
   If the software(i2c_slave_agent) is not configured for high-speed mode, the result is that the main code and address can be 
   transmitted normally, but no data will be transmitted 
    */
    rgm.IC_HS_SPKLEN.mirror(status);  //default value is 1
    rgm.IC_HS_SPKLEN.IC_HS_SPKLEN.set(0);
    rgm.IC_HS_SPKLEN.update(status);
    `uvm_do_on_with(  apb_user_config_seq, 
                      p_sequencer.apb_mst_sqr, 
                    {
                      SPEED == 3;       //config high speed mode
                      IC_10BITADDR_MASTER == 0;
                      IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                      IC_RESTART_EN == 1;  
                      TX_EMPTY_CTRL == 0;
                      ENABLE == 1;
                    } )  
      
     //IC_HS_SCL_HCNT default value is 0x6---6   IC_HS_SCL_LCNT default value is 0x10---16      
     fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })
      
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
     join     
     `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
     #10us;   

     //3.4 MHz --- 3.4 Mb/s
     rgm.IC_ENABLE.ENABLE.set(0);
     rgm.IC_ENABLE.update(status);
     rgm.IC_HS_SCL_HCNT.IC_HS_SCL_HCNT.set(15);
     rgm.IC_HS_SCL_HCNT.update(status);
     rgm.IC_HS_SCL_LCNT.IC_HS_SCL_LCNT.set(15);
     rgm.IC_HS_SCL_LCNT.update(status);
     rgm.IC_ENABLE.ENABLE.set(1);
     rgm.IC_ENABLE.update(status);
     fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })
      
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
     join     
     `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
     #10us;   
     
     //1 MHz --- 1 Mb/s
     rgm.IC_ENABLE.ENABLE.set(0);
     rgm.IC_ENABLE.update(status);
     rgm.IC_HS_SCL_HCNT.IC_HS_SCL_HCNT.set(50);
     rgm.IC_HS_SCL_HCNT.update(status);
     rgm.IC_HS_SCL_LCNT.IC_HS_SCL_LCNT.set(50);
     rgm.IC_HS_SCL_LCNT.update(status);
     rgm.IC_ENABLE.ENABLE.set(1);
     rgm.IC_ENABLE.update(status);
     fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })
      
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
     join     
     `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
     #10us;
  endtask
endclass

`endif
