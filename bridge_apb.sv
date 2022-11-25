module bridge_apb ( output reg  psel,// select signals
                    output reg  penable,      // enable signal
                    output reg  pwrite, // write signal
                    output reg [7:0] paddr,  // 8-bit address
                    output reg [7:0] pwdata, // 8-bit data                    	
                    input clk,   // clock signal
                    input rst, // negedge reset
		    input [20:0] system_bus,       
	            input [7:0] prdata    
                    );
  
  parameter IDLE = 2'd0, SETUP = 2'd1, ACCESS  = 2'd2;
  parameter READ= 2'd0, WRITE=2'd1;
  
  reg [1:0] state; 
  reg [7:0] pwdata1;
  reg [7:0] paddr1;
  reg penable1;
  reg b_psel;

  reg [7:0] sys_data;
  reg [7:0] sys_addr;
  reg [1:0] sys_kind;
 // reg  [ 1 : 0 ]      sel slave;
  reg sys_active;     
 
  
  always @ ( * )
  begin
    sys_data = system_bus [7:0];
    sys_addr = system_bus [15:8];
  //  sel slave   = system_bus [ 17 : 16 ];
    sys_kind = system_bus [19:18];
    sys_active =system_bus [20];  
  end

  always @ (posedge clk or negedge rst)
  begin//read or write
    
    if(!rst)
     pwrite <= 1'b0;
    
    else 
    begin
      if ( state == SETUP )
       begin
	 case (sys_kind)
	    READ :
	     begin
	       pwrite  <= 1'b0;
	     end
	    WRITE :
	     begin
 	       pwrite  <= 1'b1;
	     end
	  endcase
     end  
end   // always @ (posedge pclk)
 end  //reset condition
  
  
  always @ ( posedge clk or negedge rst )
  begin 
    if(!rst)
      state <= IDLE;
    else
    
  // FSM state transition

  begin 
    paddr1   = 0;
   // pwdata1  = 0;
    penable1 = 0;
    b_psel    = 0;
    state = IDLE; 

    case ( state )
      
      IDLE :  
        begin// : idle_state
          if (sys_active == 1)
          begin
              state = SETUP;
              b_psel = 4'b0;
              penable1 = 0;
          end
          else 
	      penable1 = 0;
	   end
      
      SETUP :
        begin 
           penable1  = 0;
	   paddr1 = sys_addr;
    	   pwdata1 = sys_data;
           state  = ACCESS;
        
        if ( ( sys_kind == 2'b01 ) || ( sys_kind == 2'b10 ) ) 
	             b_psel = 1'b1;
	      else if ( ( sys_kind == 2'b00 ) || ( sys_kind == 2'b11 ) )
	             state  = IDLE ;
	     end
      


      ACCESS  :
        begin            
                penable1 = 1;  
	        b_psel = 1; 
	        
	        // write
          if( sys_kind == 2'b01)
          begin             
            paddr1    = sys_addr;
            pwdata1   = sys_data;
          end 
          
          //read
          else if ( sys_kind == 2'b10 )         
                paddr1   = sys_addr;
        
          // state transition to SETUP in case of back to back write etc.,
           
          if ( ( sys_kind == 2'b01 ) || ( sys_kind == 2'b10 ) )
  	           state = SETUP;
	        else    
              state  = IDLE;          
        end //: active_state  
      
      default : state = IDLE; 
    endcase // case ( pre_state )
    
  end //: state_change
end
//assigning the internal signal values to the outputs of SLAVE

  always @ (posedge clk or negedge rst)
  begin
    if (!rst)
    begin
      psel <= 4'b0000;
      paddr <= 8'b0;
      pwdata <= 8'b0;
      penable   <= 1'b0;
      //sys_rd_data <= 8'b0;	
    end
    else if ((state == ACCESS )|| (state == SETUP) || ( sys_active == 0) )
    begin
      paddr   <= paddr1;
      pwdata  <= pwdata1;
      psel    <= b_psel;
      penable <= penable1;
      
    end
  end
  

endmodule

