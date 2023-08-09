`ifndef RKV_I2C_MASTER_ADDRESS_CG_VIRT_SEQ_SV
`define RKV_I2C_MASTER_ADDRESS_CG_VIRT_SEQ_SV

class rkv_i2c_master_address_cg_virt_seq extends rkv_i2c_base_virtual_sequence;
  bit j;
  rkv_apb_user_config_seq   apb_user_config_seq;
  bit [9:0] addr [] ='{10'b10_0111_0011, `LVC_I2C_SLAVE0_ADDRESS, 10'b00_0111_0011, 10'b01_0111_0011};
  //`LVC_I2C_SLAVE0_ADDRESS  is 10'b11_0011_0011
  `uvm_object_utils(rkv_i2c_master_address_cg_virt_seq)
  
  function new(string name = "rkv_i2c_master_address_cg_virt_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);
      
    rgm.IC_INTR_MASK.M_ACTIVITY.set(1);
    rgm.IC_INTR_MASK.M_STOP_DET.set(1);
    rgm.IC_INTR_MASK.M_START_DET.set(1);
    rgm.IC_INTR_MASK.update(status);
    
    for(j=0; j<2; j=j+1) begin  //need to config address and address_mode 7/10bit in hardware and software!!!
    `uvm_do_on_with(  apb_user_config_seq, 
                      p_sequencer.apb_mst_sqr,
                     {  
                       SPEED == 2;
                       IC_10BITADDR_MASTER == j;  //7bit address
                       IC_FS_SCL_HCNT == 200;
                       IC_FS_SCL_LCNT == 200;
                       IC_RESTART_EN  == 1;   //IC_RESTART_EN  == 0 what happen???
                       TX_EMPTY_CTRL  == 0;
                     })       
     foreach(addr[i]) begin
       cfg.i2c_cfg.slave_cfg[0].enable_10bit_addr = j;
       cfg.i2c_cfg.slave_cfg[0].slave_address = addr[i];
       env.i2c_slv.reconfigure_via_task(cfg.i2c_cfg.slave_cfg[0]);  //modify and config slave_agent address
       
       `uvm_do_on_with(  apb_user_config_seq, 
                         p_sequencer.apb_mst_sqr,
                       {  
                         IC_TAR == addr[i]; 
                  //normal_transfer 7bit:111 0011+R/W    10bit: first_byte 1111_0XX+R/W   second_byte 0111_0011
                         ENABLE == 1;
                       })
       fork
         `uvm_do_on_with( apb_write_packet_seq, p_sequencer.apb_mst_sqr, 
                         { 
                            packet.size() == 1;
                            packet[0] == 'b1111_0001;
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
       `uvm_do_on_with(  apb_user_config_seq, 
                         p_sequencer.apb_mst_sqr,
                       {  
                         IC_TAR == addr[i] + 1'b1; 
                 //unnormal_transfer  7bit:111 0100+R/W   10bit: first_byte 1111_0xx+R/W   second_byte 0111_0100  
                         ENABLE == 1;
                       })           
       fork
         `uvm_do_on_with( apb_write_packet_seq, p_sequencer.apb_mst_sqr, 
                         { 
                            packet.size() == 1;
                            packet[0] == 'b1111_0010;
                         })
           
         `uvm_do_on(  i2c_slv_write_resp_seq,    //do not control nack weather it will give a nack signal or not??? YES
                      p_sequencer.i2c_slv_sqr )
                          //{
                             //nack_addr == 0;
                             //nack_data == 0;
                             //nack_addr_count == 0;   
                          //})              
       join
       `uvm_do_on_with(apb_intr_wait_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_TX_ABRT_INTR_ID; })
       if(vif.intr[IC_TX_ABRT_INTR_ID] == 1)  
          `uvm_info(get_type_name(), "addr_tx_abrt interrupt signal is arise", UVM_LOW)    
  
       rgm.IC_TX_ABRT_SOURCE.mirror(status);
       `uvm_do_on_with(apb_intr_clear_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_TX_ABRT_INTR_ID; })
       rgm.IC_RAW_INTR_STAT.mirror(status);
       if(rgm.IC_RAW_INTR_STAT.TX_ABRT.get() == 0 && vif.intr[IC_TX_ABRT_INTR_ID] == 0) 
          `uvm_info(get_type_name(), "addr_tx_abrt interrupt signal have been clear", UVM_LOW)
     
       `uvm_do_on_with(apb_intr_clear_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_START_DET_INTR_ID; })
       `uvm_do_on_with(apb_intr_clear_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_ACTIVITY_INTR_ID; })
       `uvm_do_on_with(apb_intr_clear_seq, p_sequencer.apb_mst_sqr, { intr_id == IC_STOP_DET_INTR_ID; })
       rgm.IC_ENABLE.ENABLE.set(0);
       rgm.IC_ENABLE.update(status);
       #10us;  //need to add 10us at this point in order to finish simulation!!!
     end   
    end
     //#10us;  adding 10us at this point can't finish simulation!!!
     `uvm_info(get_type_name(), "=====================FINISH=====================", UVM_LOW)  
  endtask
  
endclass

`endif