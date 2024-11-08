module gradon_left_rom (
  input  wire    [13:0]     addr,
  output wire    [11:0]     word
);

  logic [11:0] rom [(128 * 128)];

  assign word = rom[addr];

  initial begin
    $readmemh ("../../figures/coe/gradon_left.hex",rom);
  end
  endmodule