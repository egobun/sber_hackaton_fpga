module gameover_rom (
  input  wire    [16:0]     addr,
  output wire    [11:0]     word
);

  logic [11:0] rom [(360 * 360)];

  assign word = rom[addr];

  initial begin
    $readmemh ("../../figures/coe/gameover.hex",rom);
  end

endmodule
