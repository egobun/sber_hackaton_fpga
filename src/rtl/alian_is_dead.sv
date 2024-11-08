module alian_is_dead(
input logic [9:0]   fireball_h_coord,          // Object Point(P) horizontal coodrinate
input logic [9:0]   fireball_v_coord,          // Object Point(P) vertical coordinate

input logic [9:0]   alian_h_coord,             // Object Point(P) horizontal coodrinate
input logic [9:0]   alian_v_coord,             // Object Point(P) vertical coordinate

output logic alian_is_dead
);
parameter     alian_width  = 128;         // Horizontal width
parameter     alian_height = 128;         // Vertical height

parameter     fireball_width  = 64;         // Horizontal width
parameter     fireball_height = 64;         // Vertical height

always_comb begin
    if((fireball_h_coord + fireball_width > alian_h_coord) 
    & (fireball_h_coord < alian_h_coord + alian_width) 
    & (fireball_v_coord + fireball_height > alian_v_coord) 
    & (fireball_v_coord < alian_v_coord + alian_height)
    & (fireball_h_coord < alian_h_coord + fireball_width)
    ) begin
        alian_is_dead = 1'b1;
    end else 
    alian_is_dead = 1'b0;
end

// always_comb begin
//     if((fireball_h_coord + fireball_width > alian_h_coord) & (fireball_v_coord + fireball_height > alian_v_coord)) begin
//         alian_is_dead = 1'b1;
//     end else if((fireball_h_coord < alian_h_coord + alian_width) & (fireball_v_coord + fireball_height > alian_v_coord))begin
//         alian_is_dead = 1'b1;
//     end else if((fireball_h_coord + fireball_width > alian_h_coord) & (fireball_v_coord < alian_v_coord + alian_height))begin
//         alian_is_dead = 1'b1;
//     end else if((fireball_h_coord < alian_h_coord + fireball_width) & (fireball_v_coord < alian_v_coord + alian_height))begin
//         alian_is_dead = 1'b1;
//     end else 
//     alian_is_dead = 1'b0;
// end

endmodule