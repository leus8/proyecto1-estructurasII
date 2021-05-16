module pshare 
  #(
  parameter     Direction_SIZE  = 32,
  parameter     Table_SIZE = 100
  )
 (
  input  clk,
  input  reset,
  input  was_branch,
  input  branch_result, //Taken or Not taken.
  input  [Direction_SIZE-1:0] next_PC, // Jump direction
  input [Direction_SIZE-1:0] direction, 
  output reg prediction, //Take it or not take it.
  output reg [Direction_SIZE-1:0] predicted_PC,
  output reg [31:0]total_branch
 );
  //output reg [31:0]past_past_direction

 integer i,j;
 reg [Direction_SIZE-1:0] direction_reg;
 reg [Direction_SIZE-1:0] past_direction;
 reg [Direction_SIZE-1:0] past_past_direction;
 reg [Direction_SIZE-1:0] past_past_past_direction;
 reg branch_reg;
 reg past_branch;
 reg past_past_branch;
 //reg prediction;
 //reg total_branch;
 //00 SN
 //01 WN
 //10 WT
 //11 ST
 reg [Direction_SIZE -1 :0] history_table [0:Table_SIZE - 1];// contiene direcciones
 reg [1:0]state_dir [0:Table_SIZE - 1]; // Donde se tiene el valor de la direccion
 reg [31:0]errores; //  La cantidad de errores que se tienen

 always @(*) begin
   direction_reg = direction;
   branch_reg = branch_result;
 end
  
 always @(posedge clk) begin
  if (reset == 1) begin
    //past_direction <= 0;
    total_branch = 0;
    prediction = 0;
    errores = 0;
    for (i = 0; i < Table_SIZE; i = i + 1) begin
      history_table[i] = 1;
      state_dir[i] = 1;
    end
  end
  else if (was_branch == 1)begin
    //past_direction <= direction;
    past_direction <= direction_reg;
    past_past_direction <= past_direction;
    past_past_past_direction <= past_past_direction;
    past_branch <= branch_reg;
    past_past_branch <= past_branch;
    total_branch = total_branch + 1;
    for (i = 0; i < Table_SIZE; i = i + 1) begin
      if (history_table[i] == past_past_direction) begin
          if (past_past_branch == 1 && state_dir[i] != 2'b11) begin
              if (past_past_branch == 1 && state_dir[i] != 2'b10) errores = errores + 1;
              state_dir[i] = state_dir[i] + 1;
          end
          else if (past_past_branch == 0 && state_dir[i] != 00) begin
            if (past_past_branch == 0 && state_dir[i] != 01) errores = errores + 1;
            state_dir[i] = state_dir[i] - 1;
          end
      end
    end
    i =0 ;
    if (direction != past_direction) begin
      while (i<Table_SIZE) begin
        //if (history_table[i] == past_past_past_direction) begin
        //    prediction = state_dir[i];
        //    i = 100;  
        //end
        if (history_table[i]==past_direction) begin
          i=Table_SIZE;
        end
        else if (history_table[i] == 1) begin
            history_table[i] = past_direction;
            i = Table_SIZE ;     
        end
        i = i + 1;
      end
    end
    i =0 ;
    while (i<Table_SIZE) begin
      if (history_table[i] == past_direction) begin
          //prediction = state_dir[i];
          if (state_dir[i]==2'b10 || state_dir[i]==2'b11) begin
              prediction = 1;
          end
          else if (state_dir[i]==2'b01 || state_dir[i]==2'b00) begin
              prediction = 0;
          end
          i = Table_SIZE;  
      end
      i = i + 1;
    end
  end
  else if (was_branch == 0) begin
    prediction <= 0;
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

reg clk, clk_i, reset, branch_result, was_branch;
reg [31:0] addr;

integer i;
parameter     HISTORY_SIZE  = 32;
  
initial begin

  $dumpfile("test.vcd");
  $dumpvars(0);
  for (i = 0; i < 100; i = i + 1)  $dumpvars(0, U0.history_table[i], U0.state_dir[i]); 
  reset = 1;
  was_branch=1;
   @(posedge clk)
      reset <= 0;
      addr <= 16'hFFFFFFFF;
		  branch_result <= 0 ;
		
    @(posedge clk)
      reset <= 0;
      addr <= 16'hAAAAAAAA;
		  branch_result <= 1 ;
    @(posedge clk)
      reset <= 0;
      addr <= 16'hFFFFFFFFFFFF;
		  branch_result <= 0 ;
    @(posedge clk)
      reset <= 0;
      addr <= 16'hFFFFFFFFFFFF;
		  branch_result <= 1 ;
    @(posedge clk)
      reset <= 0;
      addr <= 16'hAAAAAAAA;
		  branch_result <= 1 ;
    @(posedge clk)
      reset <= 0;
      addr <= 16'hAAAAAAAA;
		  branch_result <= 1 ;
      was_branch <= 0;
    @(posedge clk)
      reset <= 0;
      addr <= 16'hFFFFFFFFFFFF;
		  branch_result <= 1 ;
		
    @(posedge clk)
      reset <= 0;
      addr <= 16'hAAAAAAAA;
		  branch_result <= 0 ;
    @(posedge clk)
      reset <= 0;
      addr <= 16'hFFFFFFFFFFFF;
		  branch_result <= 1 ;
    @(posedge clk)
      reset <= 0;
      addr <= 16'hFFFFFFFFFFFF;
		  branch_result <= 1;
      was_branch <= 1;
    @(posedge clk)
      reset <= 0;
      addr <= 16'hAAAAAAAA;
		  branch_result <= 0 ;
    @(posedge clk)
      reset <= 0;
      addr <= 16'hAAAAAAAA;
		  branch_result <= 0 ;
  $finish;
end
  
// Reloj
initial	clk 	<= 0;			// Valor inicial al reloj, sino siempre ser� indeterminado
always	#4 clk 	<= ~clk;		// Hace "toggle" cada 2*1ns
initial	clk_i 	<= 0;			// Valor inicial al reloj, sino siempre ser� indeterminado
always	#4 clk_i 	<= ~clk_i;		// Hace "toggle" cada 2*1ns

pshare U0 (
.clk (clk),
.reset (reset),
.branch_result (branch_result),
.prediction (),
.predicted_PC (),
.next_PC (addr),
.direction(addr),
.total_branch (),
.was_branch (was_branch)
);


endmodule