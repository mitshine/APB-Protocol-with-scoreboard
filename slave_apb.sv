
module slave_apb (  output reg [3:0] prdata, //dataout from slave 
                    input penable,// to enable read or write
                    input pwrite, // control signal 
                    input psel,  // select signal
                    input clk,   // posedge clk
                    input rst, // negedge reset              
                    input [7:0] paddr,  // 8-bit address            
                    input [7:0] pwdata  // 8-bit write data
                    );
  
parameter IDLE=2'b00,SETUP=2'b01,ACCESS=2'b10;


  reg [1:0]state;

  reg [7:0] slave [0:255];  // slaveory-256 bytes
  reg [7:0] prdata1;
  
  always @ (posedge clk or negedge rst )
  begin// : fsm_slave
    if (!rst)
      state = IDLE;
    else 
     begin
     prdata1 = 8'b0;
     case(state)
    
   
      IDLE   :
        begin //: idle_state
	  if ( ! penable )
	   begin
            if ( psel == 0 ) 
	     begin
              state = IDLE;
	      prdata1 = 8'b0;
             end
	    
            else if ( ( psel == 1 ) && ( penable == 0 ) )
             begin
              state = SETUP;
	     end 
	        
        end 
      end

      SETUP  :
        begin //: setup_state
	  
          if( ( psel == 1 ) && ( penable == 1) )
            begin
            state = ACCESS;
            end
        end 
      
      ACCESS :
        begin //: enable_state
	 
          if ( ( psel == 1 ) && ( penable == 0 ) )
            state  = SETUP;
	
          else
          begin //: no_transfer
            state  = IDLE;
          end //: no_transfer
          
	  if(!pwrite)        
            prdata1 = slave[paddr];
	  
          if (( psel == 0 ) && ( penable == 0 ))  
            state = IDLE;
	
        end //: enable_state
      
      default : state = IDLE;
    endcase
end

  end //: state_change
  
  always @ (posedge clk or negedge rst)
  begin 
    if (!rst)
    begin
      prdata = 8'b0;
    end  
    else
      if ( (state == ACCESS ) && ( pwrite == 0 ) )
        prdata = prdata1;
  end

  always @ (posedge clk or negedge rst)
  begin
    if ( (state == ACCESS) && (pwrite ==1) )
     begin
        slave [paddr] = pwdata; 
     end 
  end
  
endmodule
