`ifndef RKV_I2C_MASTER_HS_MASTER_CODE_VIRT_SEQ_SV
`define RKV_I2C_MASTER_HS_MASTER_CODE_VIRT_SEQ_SV

class rkv_i2c_master_hs_master_code_virt_seq extends rkv_i2c_base_virtual_sequence;
  rkv_apb_user_config_seq   apb_user_config_seq;
  `uvm_object_utils(rkv_i2c_master_hs_master_code_virt_seq)
  
  function new(string name = "rkv_i2c_master_hs_master_code_virt_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);
    
    cfg.i2c_cfg.slave_cfg[0].bus_speed = lvc_i2c_pkg::HIGHSPEED_MODE;
    env.i2c_slv.reconfigure_via_task(cfg.i2c_cfg.slave_cfg[0]);
    
    rgm.IC_HS_SPKLEN.mirror(status);
    rgm.IC_HS_MADDR.mirror(status);   //default value is 0x1
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
    
    fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 2;
                           packet[0] == 8'b1010_1010;
                           packet[1] == 8'b0101_0101;
                       })     
         
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr);    
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us; 


    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_HS_MADDR.IC_HS_MAR.set(0);
    rgm.IC_HS_MADDR.update(status);
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);           
    fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })     
         
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr);    
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us; 
    
    
    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_HS_MADDR.IC_HS_MAR.set(2);
    rgm.IC_HS_MADDR.update(status);
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);           
    fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })     
         
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr);    
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;


    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_HS_MADDR.IC_HS_MAR.set(3);
    rgm.IC_HS_MADDR.update(status);
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);           
    fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })     
         
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr);    
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
    

    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_HS_MADDR.IC_HS_MAR.set(4);
    rgm.IC_HS_MADDR.update(status);
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);           
    fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })     
         
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr);    
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
    
    
    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_HS_MADDR.IC_HS_MAR.set(5);
    rgm.IC_HS_MADDR.update(status);
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);           
    fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })     
         
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr);    
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
    
    
    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_HS_MADDR.IC_HS_MAR.set(6);
    rgm.IC_HS_MADDR.update(status);
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);           
    fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })     
         
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr);    
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
    
    
    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_HS_MADDR.IC_HS_MAR.set(7);
    rgm.IC_HS_MADDR.update(status);
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);           
    fork 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })     
         
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr);    
    join
    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;


    rgm.IC_ENABLE.ENABLE.set(0);
    rgm.IC_ENABLE.update(status);
    rgm.IC_CON.IC_RESTART_EN.set(0);
    rgm.IC_CON.update(status);
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);  
    
    fork
      while(1) begin
        rgm.IC_RAW_INTR_STAT.mirror(status);
        if(rgm.IC_RAW_INTR_STAT.TX_ABRT.get() == 1) begin
          rgm.IC_TX_ABRT_SOURCE.mirror(status);
          rgm.IC_CLR_TX_ABRT.mirror(status);
          `uvm_info(get_type_name(), "TX_ABRT interrupt has been cleared", UVM_HIGH)
          break;
          end
        else
        repeat(100) @(vif.cb_mon); 
      end
    join_none
 
       `uvm_do_on_with(  apb_write_packet_seq, 
                         p_sequencer.apb_mst_sqr, 
                       {
                           packet.size() == 1;
                           packet[0] == 8'b1010_1010;
                       })     
         
       `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr);    

    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  endtask
 
endclass
`endif
