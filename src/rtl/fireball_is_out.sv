module fireball_is_out(
    input logic [9:0]   fireball_h_coord,        // Object Point(P) horizontal coodrinate
    input logic [9:0]   fireball_v_coord,        // Object Point(P) vertical coordinate
    input logic [9:0]   fireball_h_speed,       // Horizontal Object movement speed
    input logic [9:0]   fireball_v_speed,        // Vertical Object movement speed
    output logic fireball_is_out
);

parameter     fireball_width  = 64;
parameter     fireball_height = 64;


always_comb begin
    if(fireball_h_coord < fireball_h_speed) fireball_is_out = 1'b1;
    else if ((fireball_h_coord + fireball_width + fireball_h_speed) > 10'd799) fireball_is_out = 1'b1;
    else if (fireball_v_coord < fireball_v_speed) fireball_is_out = 1'b1;
    else if ((fireball_v_coord + fireball_height + fireball_v_speed + 10'd1) > 10'd599) fireball_is_out = 1'b1;
    else fireball_is_out = 1'b0;
end


endmodule