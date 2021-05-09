module gshare
  #(
  parameter     HISTORY_SIZE  = 4
  )
 (
  input  clk_i,
  input  reset_i,
  input  branch_result, //Taken or Not taken.
  input  [31:0] next_PC, // Jump direction
  output prediction, //Take it or not take it.
  output [31:0] predicted_PC
 );

 integer i;
 
 reg [HISTORY_SIZE-1:0] global_history;
 reg [HISTORY_SIZE-1:0] global_history_prev;
 //00 WN
 //01 SN
 //10 WT
 //11 ST
 reg [1:0] pattern_history [0:2**(HISTORY_SIZE)-1]; 
 reg [31:0] PC_prediction [0:2**(HISTORY_SIZE)-1];
 reg prediction;
 reg [31:0] predicted_PC;
 
 always @(posedge clk_i) begin
  if (reset_i) begin
    global_history = 0;
    global_history_prev = 0;
  end
  else begin
    //global_history = {branch_result,global_history[HISTORY_SIZE-1:1]};
    global_history_prev = global_history;
    global_history = global_history >>1;
    global_history[HISTORY_SIZE-1] = branch_result;
  end
end 

always @(posedge clk_i) begin
    prediction = pattern_history[global_history][1];
    predicted_PC = PC_prediction[global_history];
end

always @(posedge clk_i) begin
  if (reset_i) begin
    for (i = 0; i < 2**HISTORY_SIZE; i = i + 1) begin
      pattern_history[i] = 1;
      PC_prediction[i] = 0;
    end
  end
  else begin
      if (branch_result == 1 && pattern_history[global_history_prev] != 11) begin
          pattern_history[global_history_prev] = pattern_history[global_history_prev] + 1;
          PC_prediction[global_history_prev] = next_PC;  //guardar PC_next solo en el caso Taken.
      end
      if (branch_result == 0 && pattern_history[global_history_prev] != 00)
        pattern_history[global_history_prev] = pattern_history[global_history_prev] - 1;
  end
end

endmodule

 //00 SN
 //01 WN
 //10 WT
 //11 ST

// Testbench Code Goes here
module gshare_tb;

reg clock, reset, branch;
reg [31:0] addr;

integer i;
parameter     HISTORY_SIZE  = 4;
  
initial begin

  $dumpfile("test.vcd");
  $dumpvars(0);

  for (i = 0; i < 2**HISTORY_SIZE; i = i + 1) $dumpvars(0, U0.pattern_history[i]); 
  
  clock = 0;
  reset = 0;
  #5 reset = 1;
  #15 reset = 0;
  branch=0;
  #1000
  $finish;
end

always @(posedge clock) begin
  branch = $random;
  addr = $random;
end
  
always begin
 #5 clock = !clock;
end

gshare U0 (
.clk_i (clock),
.reset_i (reset),
.branch_result (branch),
.predicted_PC (),
.next_PC (addr)
);


endmodule