module hello_team_rom (
  input  wire    [14:0]     addr,
  output wire    [11:0]     word
);

  logic [11:0] rom [(160 * 160)];

  assign word = rom[addr];

  initial begin
    $readmemh ("../../figures/coe/BB.hex",rom);
  end

endmodule
