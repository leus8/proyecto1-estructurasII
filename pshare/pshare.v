module pshare 
  #(
  parameter     Direction_SIZE  = 32
  )
 (
  input  clk,
  input  reset,
  input  branch_result, //Taken or Not taken.
  input  [Direction_SIZE-1:0] next_PC, // Jump direction
  input [Direction_SIZE-1:0] direction, 
  output prediction, //Take it or not take it.
  output reg [Direction_SIZE-1:0] predicted_PC,
  output reg total_branch
 );

 integer i;
 reg [Direction_SIZE-1:0] past_direction;
 reg prediction;
 //reg total_branch;
 //00 SN
 //01 WN
 //10 WT
 //11 ST
 reg [Direction_SIZE -1 :0] history_table [0:99];
 reg [1:0]state_dir [0:99] // Donde se tiene el valor de la direccion
 reg [31:0] errores [0:99]; //  La cantidad de errores que se tienen
 
 always @(posedge clk) begin
  if (reset == 0) begin
    past_direction = 0;
    total_branch = 0;
  end
  else begin
    past_direction = direction;
    total_branch <= total_branch + 1;
  end
end 

always @(posedge clk) begin
    prediction = history_table[direction];
    predicted_PC = PC_prediction[direction];
end

always @(posedge clk) begin
  if (reset == 0) begin
    for (i = 0; i < 2**Direction_SIZE; i = i + 1) begin
      history_table[i] = 0;
      PC_prediction[i] = 0;
    end
  end
  else begin
      if (branch_result == 1 && history_table[past_direction] != 11) begin
          history_table[past_direction] = history_table[past_direction] + 1;
          PC_prediction[past_direction] = next_PC;  //guardar PC_next solo en el caso Taken.
          if (branch_result == 1 && history_table[past_direction] != 10) begin
              errores[past_direction] = errores[past_direction] + 1;
          end
      end
      if (branch_result == 0 && history_table[past_direction] != 00)
        history_table[past_direction] = history_table[past_direction] - 1;
        if (branch_result == 1 && history_table[past_direction] != 01) begin
              errores[past_direction] = errores[past_direction] + 1;
          end
  end
end

endmodule

 //00 SN
 //01 WN
 //10 WT
 //11 ST

// Testbench Code Goes here
module gshare_tb;

reg clk, reset, branch_result;
reg [31:0] addr;

integer i;
parameter     HISTORY_SIZE  = 32;
  
initial begin

  $dumpfile("test.vcd");
  $dumpvars(0);

  for (i = 0; i < 2**HISTORY_SIZE; i = i + 1); 
  
  clk = 0;
  reset = 0;
  #5 reset = 0;
  #15 reset = 1;
  branch_result=0;
  #1000
  $finish;
end

always @(posedge clk) begin
  branch_result = $random;
  addr = $random;
end
  
always begin
 #5 clk = !clk;
end

pshare U0 (
.clk (clk),
.reset (reset),
.branch_result (branch_result),
.prediction (),
.predicted_PC (),
.next_PC (addr),
.direction(addr),
.total_branch ()
);


endmodule
