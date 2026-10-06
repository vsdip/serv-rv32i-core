`timescale 1ns/1ps

module serv_smoke_tb;
  reg clk = 0;
  reg rst = 1;
  always #5 clk = ~clk;

  wire [31:0] ibus_adr, dbus_adr, dbus_dat;
  wire ibus_cyc, dbus_cyc, dbus_we;
  wire [3:0] dbus_sel;
  reg [31:0] instruction;

  // Program:
  // x1 = 7; x2 = x1 + 5; store x2 at address 0; loop.
  always @* begin
    case (ibus_adr)
      32'h00000000: instruction = 32'h00700093; // addi x1,x0,7
      32'h00000004: instruction = 32'h00508113; // addi x2,x1,5
      32'h00000008: instruction = 32'h00202023; // sw x2,0(x0)
      32'h0000000c: instruction = 32'h0000006f; // jal x0,0
      default:      instruction = 32'h0000006f;
    endcase
  end

  serv_rf_top #(
    .RESET_PC(32'h00000000),
    .W(1),
    .WITH_CSR(1),
    .COMPRESSED(0),
    .ALIGN(0),
    .MDU(0),
    .PRE_REGISTER(1),
    .DEBUG(0),
    .RF_WIDTH(2),
    .RESET_STRATEGY("MINI")
  ) dut (
    .clk(clk),
    .i_rst(rst),
    .i_timer_irq(1'b0),
    .o_ibus_adr(ibus_adr),
    .o_ibus_cyc(ibus_cyc),
    .i_ibus_rdt(instruction),
    .i_ibus_ack(ibus_cyc),
    .o_dbus_adr(dbus_adr),
    .o_dbus_dat(dbus_dat),
    .o_dbus_sel(dbus_sel),
    .o_dbus_we(dbus_we),
    .o_dbus_cyc(dbus_cyc),
    .i_dbus_rdt(32'b0),
    .i_dbus_ack(dbus_cyc),
    .i_ext_rd(32'b0),
    .i_ext_ready(1'b0)
  );

  initial begin
    repeat (5) @(negedge clk);
    rst = 0;
    repeat (10000) @(posedge clk);
    $fatal(1, "FAIL: CPU did not reach the store instruction");
  end

  always @(posedge clk) begin
    if (!rst && dbus_cyc && dbus_we) begin
      if (dbus_adr !== 32'h0 ||
          dbus_dat !== 32'd12 ||
          dbus_sel !== 4'b1111)
        $fatal(1, "FAIL: store address=%h data=%h sel=%b",
               dbus_adr, dbus_dat, dbus_sel);
      $display("PASS: SERV executed ADDI, ADDI, SW; stored 12 at address 0");
      $finish;
    end
  end
endmodule

