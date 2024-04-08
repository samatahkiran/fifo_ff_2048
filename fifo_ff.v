`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2024 10:51:54
// Design Name: 
// Module Name: fifo_ff
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_ff( 
                input wire clk,
               input wire reset_n,
               input wire wr_en,
               
               input wire [DATA_WIDTH-1:0] s_axis_data,
               input wire s_axis_valid,
               output reg s_axis_ready,
               input wire s_axis_last,
               
               input wire rd_en,
               
               output wire full,
                
               output reg [DATA_WIDTH-1:0] m_axis_data,
               output reg m_axis_valid,
               input wire m_axis_ready,
               output reg m_axis_last,
               
               output empty             
 
            );
            
          parameter DEPTH = 2048;
          parameter DATA_WIDTH = 32;
          
          reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
          
          reg [10:0] wr_ptr;
          reg [10:0] rd_ptr;         
          reg data_last;
                                 
         reg ready_out;
         reg [DATA_WIDTH-1:0] reg_data;
         reg reg_valid;
   
         
         assign full = ((wr_ptr[10] != rd_ptr[10]) && (wr_ptr [9:0] == rd_ptr[9:0]));
         assign empty = (wr_ptr[10:0] == rd_ptr[10:0]);
          
          // handle with the write processor 
           
          always@(posedge clk) begin
              
               if(reset_n) begin                          
               
                  wr_ptr <= 0;                                
                //  reg_data <= 32'h00;
                  reg_valid <= 0;
                  data_last <= 0;
                   
                end 
                
                else begin
                  
                  if(wr_en && s_axis_valid && s_axis_ready && !full) begin
                  
                 fifo_mem[wr_ptr] <= s_axis_data;
                  
                  wr_ptr <= wr_ptr + 1;
                  data_last <= s_axis_last;
                  reg_valid <= s_axis_valid;
                                
                  end
                 
                  else begin
                  fifo_mem[wr_ptr] <= 0;
                  reg_valid <= 0;
                  data_last <= 0;
                  end
               
              end
         end
          
          //  handle with the read pointer 
          
           always@(posedge clk) begin
              
               if(reset_n) begin
               
                  rd_ptr <= 0;               
                                                     
                 // reg_valid <= 1'b0;
                  reg_data <=  32'h00;
                  //data_last <= 1'b0;                
                  
                   
                end 
                
                else begin
                  
                  if(rd_en && ~empty) begin
                  
                  reg_data <= fifo_mem[rd_ptr];                  
                                                                 
                             
                  rd_ptr <= rd_ptr + 1;                      
                  
                   
                  end
                   else begin
                   reg_data <= 0;                    
                  
                  end
               end
          end
         
          
          always @(posedge clk) begin
           if(reset_n) begin
           reg_valid <= 0;
           end
         
           else begin
           if(rd_en && ~empty )           
            reg_valid <= 1;
           
            else
            reg_valid <= 0;
           end
           end
          
          always @(posedge clk) begin
            
            if(reset_n) begin
              ready_out <= 32'h00;
            end
            
            else
              ready_out <= m_axis_ready;
            end
       

    always@(posedge clk)begin
      if(reset_n) begin
        s_axis_ready <= 0;
        m_axis_data <= 0;
        m_axis_valid <= 0;
        m_axis_last <= 0;
      end
      else if(m_axis_ready) begin
          s_axis_ready <= ready_out;
          m_axis_data  <= reg_data;
          m_axis_valid <= reg_valid;
          m_axis_last  <= data_last;
          
      end
   end          
      
      //assign rd_en = m_axis_ready?1:0;    
                     
                  
endmodule
