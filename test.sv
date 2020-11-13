// Code your testbench here
// or browse Examples
`timescale 1ns / 10ps
program test_bench (seq_interface.TEST seq_int_i);
  
  bit in_queue[$];
  initial begin
    initialize ();
    #10;
    seq_int_i.reset =1; //reset release
    #10;
    fork
      //stimulus generatoer and driver
      drive_sequence($urandom_range(100,200));
      //scoreboard
      simple_checker();
    join_any
    $finish();
  end
  
  //intialize signals to default value
  function void initialize();
    seq_int_i.sequence_in = 0;
    seq_int_i.reset = 0;
  endfunction: initialize
  
  //generate stimulus and drive on the dut
  task drive_sequence(input int length = 5);
    bit dyn_array[];
    
    dyn_array = new[length];
    foreach(dyn_array[i]) dyn_array[i]   = $random();
    
    foreach(dyn_array[i]) begin
      @(negedge seq_int_i.clock);
      seq_int_i.sequence_in   = dyn_array[i];
      in_queue.push_back(dyn_array[i]);
      $write("Drive_value = %b\t",seq_int_i.sequence_in);
    end
  endtask: drive_sequence
  
  //scoreboard :check correctness of design
  task simple_checker();
    bit pop_data;
    bit [3:0] seq_data;
    forever begin
      @(posedge seq_int_i.clock);
      if(in_queue.size  !=0) begin
        pop_data = in_queue.pop_back();
        seq_data = {seq_data,pop_data};
        if(seq_data == 'b1011) begin
          if(seq_int_i.detector_out == 1'b0)
            $display("ERROR : Sequence is not matched");
          else 
            $display("SUCCESS : sEQUENCE is detected");
        end
        else begin
          if(seq_int_i.detector_out == 1'b1)
            $display("ERROR : Errornous sequence detection");
        end
      end
    end
  endtask: simple_checker
endprogram: test_bench
  
//top level module 
module tb_top();
  bit clock;
   // clockgeneration logic
  initial begin
    clock = 0;
    forever #10 clock = ~clock;
  end
  
  seq_interface   seq_int_i(clock);
  test_bench   tb(seq_int_i);
  Sequence_Detector  dut(seq_int_i);
  
  // to dump the waveforms
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb_top);
  end
  endmodule: tb_top
      
    
