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
  output reg prediction, //Take it or not take it.
  output reg [Direction_SIZE-1:0] predicted_PC,
  output reg [32:0]total_branch
 );

 integer i;
 reg [Direction_SIZE-1:0] past_direction;
 reg [Direction_SIZE-1:0] past_past_direction;
 //reg prediction;
 //reg total_branch;
 //00 SN
 //01 WN
 //10 WT
 //11 ST
 reg [Direction_SIZE -1 :0] history_table [0:99];// contiene direcciones
 reg [1:0]state_dir [0:99]; // Donde se tiene el valor de la direccion
 reg errores; //  La cantidad de errores que se tienen
  
 always @(posedge clk) begin
  if (reset == 0) begin
    //past_direction <= 0;
    total_branch = 0;
    errores = 0;
    for (i = 0; i < 100; i = i + 1) begin
      history_table[i] = 0;
      state_dir[i] = 1;
    end
  end
  else begin
    past_direction <= direction;
    total_branch = total_branch + 1;
    for (i = 0; i < 100; i = i + 1) begin
      if (history_table[i] == past_direction) begin
          if (branch_result == 1 && state_dir[i] != 11) begin
              state_dir[i] = state_dir[i] + 1;
              if (branch_result == 1 && state_dir[i] != 10) begin
                  errores = errores + 1;
              end
          end
          if (branch_result == 0 && state_dir[i] != 00)
            state_dir[i] = state_dir[i] - 1;
            if (branch_result == 1 && state_dir[i] != 01) begin
                  errores = errores + 1;
              end
      end
    end
    i =0 ;
    if (direction != past_direction) begin
      while (i<100) begin
        if (history_table[i] == direction) begin
            prediction = state_dir[i];
            i = 100;  
        end
        else if (history_table[i] == 0) begin
            history_table[i] = past_direction;
            prediction = state_dir[i]; 
            i = 100;     
        end
        i = i + 1;
      end
    end
  end
 end 

 //always @(negedge clk) begin
 // past_direction <= direction;
//end


endmodule

 //00 SN
 //01 WN
 //10 WT
 //11 ST

// Testbench Code Goes here
module gshare_tb;

reg clk, clk_i, reset, branch_result;
reg [31:0] addr;

integer i;
parameter     HISTORY_SIZE  = 32;
  
initial begin

  $dumpfile("test.vcd");
  $dumpvars(0);
  for (i = 0; i < 100; i = i + 1)  $dumpvars(0, U0.history_table[i], U0.state_dir[i]); 
  clk = 0;
  reset = 0;
  #15 reset = 1;
  branch_result=0;
  #1000
  $finish;
end

always @(posedge clk) begin
  branch_result = $random;
  addr = $random;
end
  
// Reloj
initial	clk 	<= 0;			// Valor inicial al reloj, sino siempre ser� indeterminado
always	#4 clk 	<= ~clk;		// Hace "toggle" cada 2*1ns
initial	clk_i 	<= 0;			// Valor inicial al reloj, sino siempre ser� indeterminado
always	#4 clk_i 	<= ~clk_i;		// Hace "toggle" cada 2*1ns

pshare U0 (
.clk (clk_i),
.reset (reset),
.branch_result (branch_result),
.prediction (),
.predicted_PC (),
.next_PC (addr),
.direction(addr),
.total_branch ()
);


endmodule