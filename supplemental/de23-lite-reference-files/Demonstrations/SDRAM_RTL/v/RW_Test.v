module RW_Test (
      iCLK,
		iRST_n,
		iBUTTON,
	   write,
		writedata,
	   read,
		readdata,
      drv_status_pass,
		drv_status_fail,
		drv_status_test_complete,
		c_state,		
      same
);

parameter      ADDR_W             =     24;
parameter      DATA_W             =     32;

input          iCLK;
input          iRST_n;
input          iBUTTON;

output         write;
output [DATA_W-1:0]	writedata;
output	      read;
input	 [DATA_W-1:0]  readdata;
	
output		   drv_status_pass;
output		   drv_status_fail;
output		   drv_status_test_complete;
output         same;
output [3:0]   c_state;		

//=======================================================
//  Signal declarations
//=======================================================

reg  [1:0]           pre_button;
reg                  trigger;
reg  [3:0]           c_state;		
reg	               write, read;
reg  [ADDR_W-1:0]    address;  
reg  [DATA_W-1:0]    writedata;
reg  [4:0]           write_count;
wire                 max_address;
wire                 same;

assign max_address = &address;
assign same = readdata == writedata;

wire [31:0]          y0, y1, y2;
wire [7:0]           z;
wire [DATA_W-1:0]    y;	
reg  [31:0]          cal_data,clk_cnt;

//--pass
assign y0 = cal_data + {8'b0, address};
assign y1 = {y0[15:0], y0[31:16]} ^ cal_data;
assign y2 = y1 + cal_data;
//------


////--pass
//assign y0 = address;
//assign y1 = {y0[15:0], y0[31:16]};
//assign y2 = y1 ^ address;
//------
assign z = y1[7:0] + y2[7:0];
//                7       3   6  
//assign y = { 2{y2[28:22],z[7:5],y1[10:5]}} ;

wire [15:0]t; 
assign t=16'hffff_ffff ^ address[15:0] ;
assign y ={ t  ,address[15:0] } ;


always@(posedge iCLK)
  if (trigger)//iRST_n)
  	 clk_cnt <= 32'b0;
  else  
  	 clk_cnt <= clk_cnt + 32'b1;

always@(posedge iCLK)
begin
	if (!iRST_n)
	begin 
		pre_button  <= 2'b11;
		trigger     <= 1'b0;
		write_count <= 5'b0;
		c_state     <= 4'b0;
		write       <= 1'b0;
		read        <= 1'b0;
		writedata   <= 16'b0;
	 end
	else
	begin
	   pre_button <= {pre_button[0], iBUTTON};
		trigger <= !pre_button[0] && pre_button[1];

	  case (c_state)
	  	0 : begin //idle
	  		address <= {ADDR_W{1'b0}};

	  			if (trigger)
	  		begin
	  			c_state <= 1;
				cal_data<=clk_cnt;
	  		end

	  	end
	  	1 : begin //write
	  		
	  		if (write_count[3])
	  		begin
	  		  write_count <= 5'b0;
	  		  write       <= 1'b1;
			  writedata   <= y;
	  		  c_state     <= 2;
	  		end
	  	  else
	  	  	write_count <= write_count + 1'b1;
		 end
	  	2 : begin //finish write one data
	  		   write <= 1'b0;
	  			c_state <= 3;
	  		end
	  	3 : begin
	  	   if (max_address) //finish write all(burst) 
	  		begin
		      address <=  {ADDR_W{1'b0}};
				c_state <= 10;
         end
		else //write the next data
	  		begin
	  			address <= address + 1'b1;
	  			c_state <= 1;
	  		end
		end
			
		10 : c_state <= 11;
		11 : c_state <= 4;
	  	4 : begin //read
	  			read <= 1;
			
	       if (!write_count[3])
	  			write_count <= write_count + 1'b1;
	  		
	  		   c_state <= 5;
	  	end
	  	5 : begin //latch read data
	  		read <= 0;
 		   writedata <= y;
		  
		  if (!write_count[3])
	  			write_count <= write_count + 5'b1;

	  	   c_state <= 6;
       end
	 // 	6 : begin //finish compare one data
	 // 		if (write_count[3])
	 // 		begin
	 // 			write_count <= 5'b0;
	 //		c_state <= 7;
	 // 			//if (same)
	 // 				//c_state <= 7;
	 // 			//else
	 //          // c_state <= 8;
    //    end
    //    else
    //    	write_count <= write_count + 1'b1;
	 // 	end
	 
	 	6 : begin //finish compare one data
	  		if (write_count[3])
	  		begin
	  			write_count <= 5'b0;
	  			if (same)
	  				c_state <= 7;
	  			else
	            c_state <= 8;
        end
        else
        	write_count <= write_count + 1'b1;
	  	end
	  	7 : begin
		
	  	  if (max_address) //finish compare all 
	  		begin
	  			address <=  {ADDR_W{1'b0}};
			   c_state <= 9;
	  		end
	  		else //compare the next data
          begin
	  			address <= address + 1'b1;
            c_state <= 4;
  		 end
		end
		8 : c_state <= 8;//FAIL
		9 : c_state <= 9;//PASS
	    default : c_state <= 0;
	  endcase
  end
end
		
// test result
assign drv_status_pass = (c_state == 9) ? 1 : 0;
assign drv_status_fail = (c_state == 8) ? 1 : 0;
assign drv_status_test_complete = drv_status_pass || drv_status_fail;

endmodule 