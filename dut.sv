// Code your design here
//interface block
interface seq_interface(input clock);
  logic reset;
  logic sequence_in; //binary input
  logic detector_out;//output of sequenc detector
  
  modport TEST (input detector_out, clock, output reset, sequence_in);
  modport DUT (output detector_out, input clock,reset, sequence_in);
  
endinterface: seq_interface


//main dut block
module Sequence_Detector (seq_interface.DUT seq_int_i, input clock);
  typedef enum bit [2:0] {ZERO, ONE,ONE_ZERO, ONE_ZERO_ONE, ONE_ZERO_ONE_ONE } SEQ_e;
  reg [2:0] current_state, next_state; //ccurrent state and next state
  
  //current state sequentialcircuit
  always @(posedge seq_int_i.clock, posedge seq_int_i.reset) begin
    if(seq_int_i.reset == 0) current_state <= ZERO; //reset state
    else                     current_state <= next_state; //next state
  end
  
  //next state logic
  always_comb begin
    case(current_state)
      
      ZERO : begin
        if(seq_int_i.sequence_in==1) next_state <= ONE;
        else                         next_state <= ZERO;
      end
      
      ONE : begin
        if(seq_int_i.sequence_in==0) next_state <= ONE_ZERO;
        else                         next_state <= ONE;
      end
      
      ONE_ZERO : begin
        if(seq_int_i.sequence_in==0) next_state <= ZERO;
        else                         next_state <= ONE_ZERO_ONE;
      end
      
       ONE_ZERO_ONE : begin
         if(seq_int_i.sequence_in==0) next_state <= ONE_ZERO;
        else                         next_state <= ONE_ZERO_ONE_ONE;
      end
      
       ONE_ZERO_ONE_ONE : begin
         if(seq_int_i.sequence_in==0) next_state <= ONE_ZERO;
        else                         next_state <= ONE;
      end
      
      default : next_state <= ZERO;
    endcase
  end
  
  //combinational logic to determine the output (based on the current state )
  always @(current_state) begin
    case(current_state)
      ZERO              : seq_int_i.detector_out <= 0;
      ONE               : seq_int_i.detector_out <= 0;
      ONE_ZERO          : seq_int_i.detector_out <= 0;
      ONE_ZERO_ONE      : seq_int_i.detector_out <= 1;
      ONE_ZERO_ONE_ONE  : seq_int_i.detector_out <= 1;
      default           : seq_int_i.detector_out <= 0;
    endcase
  end
endmodule

      
      
      
      
