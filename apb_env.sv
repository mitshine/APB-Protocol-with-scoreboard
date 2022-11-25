
`include "apb_agent.sv"
`include "apb_scoreboard.sv"

class apb_env extends uvm_env;
  
  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
  apb_agent agent;
  apb_scoreboard scb;
  
  `uvm_component_utils(apb_env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //---------------------------------------
  // build_phase - crate the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

   agent = apb_agent::type_id::create("agent", this);
   scb  = apb_scoreboard::type_id::create("scb", this);
  endfunction 
  
  //---------------------------------------
  // connect_phase - connecting monitor and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    agent.monitor.item_collected_port.connect(scb.item_collected_export);
  endfunction 

endclass
