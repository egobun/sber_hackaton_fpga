module fireball_rom (
  input  wire    [11:0]     addr,
  output wire    [11:0]     word
);

  logic [11:0] rom [(64 * 64)];

  assign word = rom[addr];

  initial begin
    $readmemh ("../../figures/coe/fireball.hex",rom);
  end
endmodule