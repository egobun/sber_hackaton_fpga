module game (
  //--------- Clock & Resets                     --------//
    input  wire           pixel_clk ,  // Pixel clock 36 MHz
    input  wire           rst_n     ,  // Active low synchronous reset
  //--------- Buttons                            --------//
    input  wire           button_c  ,
    input  wire           button_u  ,
    input  wire           button_d  ,
    input  wire           button_r  ,
    input  wire           button_l  ,
  //--------- Accelerometer                      --------//
    input  wire  [7:0]    accel_data_x         ,
    input  wire  [7:0]    accel_data_y         ,
    output logic [7:0]    accel_x_end_of_frame ,
    output logic [7:0]    accel_y_end_of_frame ,
  //--------- Pixcels Coordinates                --------//
    input  wire  [10:0]   h_coord   ,
    input  wire  [ 9:0]   v_coord   ,
  //--------- VGA outputs                        --------//
    output reg  [3:0]    red       ,  // 4-bit color output
    output reg  [3:0]    green     ,  // 4-bit color output
    output reg  [3:0]    blue      ,  // 4-bit color output
  //--------- Switches for background colour     --------//
    input  wire  [2:0]    SW        ,
  //--------- Regime                             --------//
    output wire  [1:0]    demo_regime_status
);

//------------------------- Variables                    ----------------------------//
  //----------------------- Regime control               --------------------------//
    wire              change_regime ;
    reg       [1:0]   regime_store  ;         // Two demonstration regimes
  //----------------------- Counters                     --------------------------//
    parameter         FRAMES_PER_ACTION = 2;  // Action delay
    logic     [31:0]  frames_cntr ;
    logic             end_of_frame;           // End of frame's active zone
  //----------------------- Accelerometr                 --------------------------//
    parameter     ACCEL_X_CORR = 8'd3;        // Accelerometer x correction
    parameter     ACCEL_Y_CORR = 8'd1;        // Accelerometer y correction
    wire   [7:0]  accel_data_x_corr  ;        // Accelerometer x corrected data
    wire   [7:0]  accel_data_y_corr  ;        // Accelerometer y corrected data
  //----------------------- Object (Stick)               --------------------------//
    //   0 1         X
    //  +------------->
    // 0|
    // 1|  P.<v,h>-> width
    //  |   |
    // Y|   |
    //  |   V heigh
    //  |
    //  V
    parameter     gradon_width  = 128;         // Horizontal width
    parameter     gradon_height = 128;         // Vertical height
    parameter     fireball_width  = 64;         // Horizontal width
    parameter     fireball_height = 64;         // Vertical height
    logic [4:0]   object_draw        ;         // Is Sber Logo or demo object coordinate (with width and height)?
    logic [9:0]   gradon_h_coord     ;         // Object Point(P) horizontal coodrinate
    logic [9:0]   gradon_v_coord     ;         // Object Point(P) vertical coordinate
    logic [9:0]   gradon_h_speed     ;         // Horizontal Object movement speed
    logic [9:0]   gradon_v_speed     ;         // Vertical Object movement speed
    logic [9:0]   fireball_h_coord     ;         // Object Point(P) horizontal coodrinate
    logic [9:0]   fireball_v_coord     ;         // Object Point(P) vertical coordinate
    logic [9:0]   fireball_h_speed     ;         // Horizontal Object movement speed
    logic [9:0]   fireball_v_speed     ;         // Vertical Object movement speed

    parameter     alian_width  = 128;         // Horizontal width
    parameter     alian_height = 128;         // Vertical height
    logic [9:0]   alian_h_coord     ;         // Object Point(P) horizontal coodrinate
    logic [9:0]   alian_v_coord     ;         // Object Point(P) vertical coordinate
    logic [9:0]   alian_h_speed     ;         // Horizontal Object movement speed

    logic [9:0] alian_v_speed;


  //----------------------- Sber logo timer              --------------------------//
    logic [31:0]  sber_logo_counter     ;      // Counter is counting how long showing Sber logo
    wire          sber_logo_active      ;      // Demonstrating Sber logo

    logic         gameover_logo_active  ;
    // Read only memory (ROM) for sber logo file
    wire  [11:0]  sber_logo_rom_out     ;
    wire  [13:0]  sber_logo_read_address;

    wire  [11:0]  hello_team_rom_out     ;
    wire  [14:0]  hello_team_read_address;

    wire  [11:0]  gameover_logo_rom_out     ;
    wire  [16:0]  gameover_logo_read_address;

    wire  [11:0]  hero1_rom_out     ;
    wire  [13:0]  hero1_read_address;

    wire  [11:0]  fireball_rom_out     ;
    wire  [11:0]  fireball_read_address;

    wire  [11:0]  gradon_left_rom_out     ;
    wire  [13:0]  gradon_left_read_address;

    wire  [11:0]  gradon_right_rom_out     ;
    wire  [13:0]  gradon_right_read_address;

    wire  [11:0]  fon_rom_out     ;
    wire  [18:0]  fon_read_address;
//------------------------- End of Frame                 ----------------------------//
  // We recount game object once at the end of display counter //
  always_ff @( posedge pixel_clk ) begin
    if ( !rst_n )
      end_of_frame <= 1'b0;
    else
      end_of_frame <= (h_coord[9:0]==10'd799) && (v_coord==10'd599); // 799 x 599
  end
  always_ff @( posedge pixel_clk ) begin
    if ( !rst_n )
      frames_cntr <= 0;
    else if ( frames_cntr == FRAMES_PER_ACTION )
      frames_cntr <= 0;
    else if (end_of_frame)
      frames_cntr <= frames_cntr + 1;
  end

//------------------------- Regime control               ----------------------------//
  always @ ( posedge pixel_clk ) begin //Right now there are 2 regimes
    if ( !rst_n ) begin
      regime_store <= 2'b11;
    end
    else if (change_regime && (regime_store == 2'b10)) begin
      regime_store <= 2'b11;
    end
    else if ( change_regime ) begin
      regime_store <= regime_store - 1'b1;
    end
  end
  assign change_regime      = button_c    ;
  assign demo_regime_status = regime_store;

//------------------------- Accelerometr at the end of frame-------------------------//
  always @ ( posedge pixel_clk ) begin
    if ( !rst_n ) begin
      accel_x_end_of_frame <= 8'h0000000;
      accel_y_end_of_frame <= 8'h0000000;
    end
    else if ( end_of_frame && (frames_cntr == 0) ) begin
      accel_x_end_of_frame <= accel_data_x_corr;
      accel_y_end_of_frame <= accel_data_y_corr;
    end
  end
  // Accelerometr corrections
  assign accel_data_x_corr = accel_data_x + ACCEL_X_CORR;
  assign accel_data_y_corr = accel_data_y + ACCEL_Y_CORR;
//------------------------- Object movement in 2 regimes  ----------------------------//
  assign gradon_v_speed = 10'd1;
  assign gradon_h_speed = 10'd1;
  always @ ( posedge pixel_clk ) begin
    if ( !rst_n ) begin // Put object in the center
      gradon_h_coord <= 399;
      gradon_v_coord <= 99;
      fireball_h_coord <= 490;
      fireball_v_coord <= 180;
      fireball_h_speed <= 1;
      fireball_v_speed <= 1;
    end
    else if ( end_of_frame && (frames_cntr == 0) ) begin
        if ( button_l ) begin           // Moving left
          if ( gradon_h_coord < gradon_h_speed)
            gradon_h_coord <= 0;
          else
            gradon_h_coord <= gradon_h_coord - gradon_h_speed;
        end
        else if ( button_r ) begin
          if ( gradon_h_coord + gradon_h_speed + gradon_width >= 10'd799 )
            gradon_h_coord <= 10'd799 - gradon_width;
          else
            gradon_h_coord <= gradon_h_coord + gradon_h_speed;
        end
        //
        if      ( button_u ) begin
          if ( gradon_v_coord < gradon_v_speed )
            gradon_v_coord <= 0;
          else
            gradon_v_coord <= gradon_v_coord - gradon_v_speed;
        end
        else if ( button_d  ) begin
          if ( gradon_v_coord + gradon_v_speed + gradon_height >= 10'd599 )
            gradon_v_coord <= 10'd599 - gradon_height;
          else
            gradon_v_coord <= gradon_v_coord + gradon_v_speed;
        end
        //ACCELEROMETR AND FIREBALL MECHANICS
        if(SW[0]) begin
          fireball_h_coord <= gradon_h_coord + fireball_width + 10'd20;
        end 
        else begin
          if      ( !accel_data_y_corr[7] && ( accel_data_y_corr != 8'h00 )) begin
            if ( fireball_h_coord < fireball_h_speed)
              fireball_h_coord <= 0;
            else
              fireball_h_coord <= fireball_h_coord - fireball_h_speed;
          end
          else if ( accel_data_y_corr[7] && ( accel_data_y_corr != 8'h00 ) ) begin
            if ( fireball_h_coord + fireball_h_speed + fireball_width >= 10'd799 )
              fireball_h_coord <= 10'd799 - fireball_width;
            else
              fireball_h_coord <= fireball_h_coord + fireball_h_speed;
          end
        end
        //
        if(SW[0]) begin
          fireball_v_coord <= gradon_v_coord + fireball_height + 10'd20;
        end else begin
          if      ( accel_data_x_corr[7] && ( accel_data_x_corr != 8'h00 ) ) begin
            if ( fireball_v_coord < fireball_v_speed )
              fireball_v_coord <= 0;
            else
              fireball_v_coord <= fireball_v_coord - fireball_v_speed;
          end
          else if (!accel_data_x_corr[7] && ( accel_data_x_corr != 8'h00 ) )  begin
            if ( fireball_v_coord + fireball_v_speed + fireball_height >= 10'd599 )
              fireball_v_coord <= 10'd599 - fireball_height;
            else
              fireball_v_coord <= fireball_v_coord + fireball_v_speed;
          end
        end
      end
    
  end

//---------------------------------------------------------------------------------------------------


logic [31:0] clk_counter;
  always @ ( posedge pixel_clk ) begin
    if(!rst_n) begin
      clk_counter <= 32'd0;
    end else begin
      clk_counter <= clk_counter + 1'd1;
      
    end
  end

  wire enable_clk  = (clk_counter[16:0] == '0);
  wire enable_jump = (clk_counter[18:0] == '0);
  wire enable_random = (clk_counter[25:0] == '0);
  logic [9:0] jump_coordinate;
  logic [9:0] jump_length;

  logic forse;
  assign jump_length = 10'd100;
  
  always_ff @ (posedge pixel_clk)
    if (!rst_n) begin
      state <= S0;
      alian_v_coord <= 10'd355;
      
      jump_coordinate <= 10'd299;
    end
    else begin
      
      if (enable_jump)
      
      state <= next_state;
    end

  typedef enum bit [2:0]
  {
    S0 = 3'd0,
    S1 = 3'd1,
    S2 = 3'd2
  }
  state_e;

  state_e state, next_state;

always_comb begin
    case (state)
        S0: if (alian_h_coord == jump_coordinate + 10'd100) next_state = S1;
        S1: if ((alian_h_coord == jump_coordinate + 10'd100 + jump_length/2) || (alian_h_coord == jump_coordinate + 10'd100- jump_length/2)) next_state = S2;
        S2: if ((alian_h_coord == jump_coordinate + 10'd100 + jump_length) || (alian_h_coord == jump_coordinate + 10'd100- jump_length)) next_state = S0;
        default: next_state = state; // явная установка по умолчанию
    endcase
end

    always_comb begin
    if((state == S0) & (alian_h_coord != jump_coordinate + 10'd100)) begin
      alian_v_coord_copy = alian_v_coord;
      //alian_v_speed = 10'd0;
      //forse = 1'd0;
    end
    else if((state == S0) & ( alian_h_coord == jump_coordinate + 10'd100)) begin 
      alian_v_coord_copy = alian_v_coord - alian_v_speed;
      //alian_v_speed = 10'd1;
      //forse = 1'd0;
    end
    else if((state == S1) & ((alian_h_coord == jump_coordinate  + 10'd100+ jump_length/2) || (alian_h_coord == jump_coordinate + 10'd100- jump_length/2))) begin
      alian_v_coord_copy = alian_v_coord + alian_v_speed;
      //alian_v_speed = 10'd1;
      //forse = 1'd1;
    end
    else if((state == S1) & ((alian_h_coord != jump_coordinate + 10'd100 + jump_length/2) & (alian_h_coord != jump_coordinate + 10'd100- jump_length/2))) begin
      alian_v_coord_copy = alian_v_coord - alian_v_speed;
      //alian_v_speed = 10'd1;
      //forse = 1'd0;
    end
    else if((state == S2) & ((alian_h_coord == jump_coordinate  + 10'd100+ jump_length) || (alian_h_coord == jump_coordinate + 10'd100- jump_length))) begin
      alian_v_coord_copy = alian_v_coord;
      //alian_v_speed = 10'd0;
      //forse = 1'd1;
    end
    else if((state == S2) & ((alian_h_coord != jump_coordinate  + 10'd100 + jump_length) & (alian_h_coord != jump_coordinate + 10'd100- jump_length))) begin
      alian_v_coord_copy = alian_v_coord + alian_v_speed;
      //alian_v_speed = 10'd1;
      //forse = 1'd1;
    end else begin
      alian_v_coord_copy = alian_v_coord;
      //alian_v_speed = 10'd0;
      //forse = 1'd1;
    end
  end

  logic [9:0] alian_v_coord_copy;
  assign alian_h_speed = 10'd1;
  assign alian_v_speed = 10'd1;
  logic move;
  always @ ( posedge pixel_clk ) begin
    if ( !rst_n ) begin // Put object in the center
      alian_h_coord <= 10'd9;

      move <= 1'b1;
    end
    else if(enable_clk) begin
      alian_v_coord <= alian_v_coord_copy/* + ((-1)**(~forse))*alian_v_speed*/;
      if ( move ) begin           
        if ( alian_h_coord < alian_h_speed) begin
          alian_h_coord <= 0;          
          move <= ~move;
        end
        else
          alian_h_coord <= alian_h_coord - alian_h_speed;
      end
      else if ( ~move ) begin
        if ( alian_h_coord + alian_h_speed + alian_width >= 10'd799) begin
          alian_h_coord <= 10'd799 - alian_width;
          move <= ~move;
        end
        else
          alian_h_coord <= alian_h_coord + alian_h_speed;
      end
    end
  end

//------------- Sber logo on reset                               -------------//
  //----------- How long to show Sber logo                       -----------//
    always @ ( posedge pixel_clk ) begin
      if      ( !rst_n )
        sber_logo_counter <= 32'b0;
      else if ( sber_logo_counter <= 32'd2_00000000 )
        sber_logo_counter <= sber_logo_counter + 1'b1;
    end
    assign sber_logo_active = ( sber_logo_counter < 32'd2_00000000 );
    //assign gameover_logo_active = alian_is_dead;

  //----------- SBER logo ROM                                    -----------//
    // Screen resoulution is 800x600, the logo size is 128x128. We need to put the logo in the center.
    // Logo offset = (800-128)/2=336 from the left edge; Logo v coord = (600-128)/2 = 236
    // Cause we need 1 clock for reading, we start erlier
    assign sber_logo_read_address = {3'b0, h_coord} - 14'd335 + ({4'b0, v_coord} - 14'd235)*14'd128;
    assign hello_team_read_address = {4'b0, h_coord} - 15'd319 + ({5'b0, v_coord} - 15'd379)*15'd160;
    assign gameover_logo_read_address = {6'b0, h_coord} - 17'd219 + ({6'b0, v_coord} - 17'd119)*17'd360;
    assign hero1_read_address = {3'b0, h_coord} - {4'b0,alian_h_coord} + ({4'b0, v_coord} - {4'b0,alian_v_coord})*14'd128;
    assign gradon_left_read_address = {3'b0, h_coord} - {4'b0,gradon_h_coord} + ({4'b0, v_coord} - {4'b0,gradon_v_coord})*14'd128;
    assign gradon_right_read_address = {3'b0, h_coord} - {4'b0,gradon_h_coord} + ({4'b0, v_coord} - {4'b0,gradon_v_coord})*14'd128;
    assign fireball_read_address = {1'b0,h_coord} - {2'b0,fireball_h_coord} + ({2'b0, v_coord} - {2'b0,fireball_v_coord})*12'd64;
    assign fon_read_address = {8'b0, h_coord} + ({9'b0, v_coord})*14'd800;
    //for picture with size 128x128 we need 16384 pixel information
    sber_logo_rom sber_logo_rom (
      .addr ( sber_logo_read_address ),
      .word ( sber_logo_rom_out      ) 
    );

    hello_team_rom hello_team_rom (
      .addr ( hello_team_read_address ),
      .word ( hello_team_rom_out      ) 
    );

    gameover_rom gameover_rom (
      .addr ( gameover_logo_read_address ),
      .word ( gameover_logo_rom_out      ) 
    );

    hero1_rom hero1_rom (
      .addr ( hero1_read_address ),
      .word ( hero1_rom_out      ) 
    );

    fireball_rom fireball_rom (
      .addr ( fireball_read_address ),
      .word ( fireball_rom_out      ) 
    );

    gradon_left_rom gradon_left_rom (
      .addr ( gradon_left_read_address ),
      .word ( gradon_left_rom_out      ) 
    );

    gradon_right_rom gradon_right_rom (
      .addr ( gradon_right_read_address ),
      .word ( gradon_right_rom_out      ) 
    );

    fon_rom fon_rom (
      .addr ( fon_read_address ),
      .word ( fon_rom_out      ) 
    );
//____________________________________________________________________________//


// ------------ FIREBALL IS OUT ----------------------------------------------//
logic fireball_is_out;
fireball_is_out fireball_in_out(.*);


//------------- ALIAN IS DEAD ------------------------------------------------//
logic alian_is_dead;
alian_is_dead alian_dead(.*);


//-------------МОЖНО ЛИ ТАК ДЕЛАТЬ????????------------------------------------//
/*always_ff begin
  if (!rst_n)
    gameover_logo_active = 1'b0;
  else if(alian_is_dead)
    gameover_logo_active = 1'b1;
  else 
    gameover_logo_active = gameover_logo_active;
end*/
assign gameover_logo_active = alian_is_dead;

//------------- RGB MUX outputs                                  -------------//
  always_comb begin
    if ( sber_logo_active ) begin
      if((h_coord[9:0] >= 10'd335) & (h_coord[9:0] < 10'd463) & (v_coord >= 10'd235) & (v_coord < 10'd363) & ~(sber_logo_rom_out[11:0]==12'h000))
      begin
        object_draw = 5'd1;
      end else if( (h_coord[9:0] >= 10'd319) & (h_coord[9:0] < 10'd479) & (v_coord >= 10'd359) & (v_coord < 10'd519)   & ~(hello_team_rom_out[11:0]==12'h000) )
        object_draw = 5'd4;
      else begin
        object_draw = 5'd0;
      end
    end

    else if ( gameover_logo_active ) begin
      if((h_coord[9:0] >= 10'd219) & (h_coord[9:0] < 10'd579) & (v_coord >= 10'd119) & (v_coord < 10'd479) & ~(gameover_logo_rom_out[11:0]==12'h000))
      begin
        object_draw = 5'd1;
      end
      else begin
        object_draw = 5'd0;
      end
    end

    else begin
      if(( h_coord[9:0] >= fireball_h_coord ) & ( h_coord[9:0] <= (fireball_h_coord + fireball_width  )) &
                    ( v_coord >= fireball_v_coord ) & ( v_coord <= (fireball_v_coord + fireball_height ))) begin
        object_draw = 5'd3;
      end else if(( h_coord[9:0] >= gradon_h_coord ) & ( h_coord[9:0] <= (gradon_h_coord + gradon_width  )) &
                    ( v_coord >= gradon_v_coord ) & ( v_coord <= (gradon_v_coord + gradon_height ))) begin
        object_draw = 5'd1;
      end else if(( h_coord[9:0] >= alian_h_coord ) & ( h_coord[9:0] <= (alian_h_coord + alian_width  )) &
                    ( v_coord >= alian_v_coord ) & ( v_coord <= (alian_v_coord + alian_height ))) begin
        object_draw = 5'd2;
      end else begin
        object_draw = 5'd0;
      end
    end
  end

  always_comb begin
    if(sber_logo_active)begin
      if(object_draw == 5'd1) begin
        red     = sber_logo_rom_out[3:0];
        green   = sber_logo_rom_out[7:4];
        blue    = sber_logo_rom_out[11:8];
      end else if(object_draw == 5'd4) begin
        red     = hello_team_rom_out[3:0];
        green   = hello_team_rom_out[7:4];
        blue    = hello_team_rom_out[11:8];
      end else begin
        red     = (4'h0);
        green   = (4'h0);
        blue    = (4'h0);
      end
    end 

    else if(gameover_logo_active)begin
      if(object_draw == 5'd1) begin
        red     = gameover_logo_rom_out[3:0];
        green   = gameover_logo_rom_out[7:4];
        blue    = gameover_logo_rom_out[11:8];
      end else begin
        red     = 4'h0;
        green   = 4'h0;
        blue    = 4'h0;
      end
    end 

    else begin
      if(object_draw == 5'd3) begin
        if((fireball_rom_out[3:0] == 4'd0 & fireball_rom_out[7:4] == 4'd0 & fireball_rom_out[11:8] == 4'd0) || (fireball_is_out)) begin
          red     = fon_rom_out[3:0];
          green   = fon_rom_out[7:4];
          blue    = fon_rom_out[11:8];
        end else begin
            red     = fireball_rom_out[3:0];
            green   = fireball_rom_out[7:4];
            blue    = fireball_rom_out[11:8];
        end
      end else if(object_draw == 5'd1) begin
        if(button_l) begin
          if(gradon_left_rom_out[3:0] == 4'd0 & gradon_left_rom_out[7:4] == 4'd0 & gradon_left_rom_out[11:8] == 4'd0) begin
            red     = fon_rom_out[3:0];
            green   = fon_rom_out[7:4];
            blue    = fon_rom_out[11:8];
          end else begin
            red     = gradon_left_rom_out[3:0];
            green   = gradon_left_rom_out[7:4];
            blue    = gradon_left_rom_out[11:8];
          end
        end else begin
          if(gradon_right_rom_out[3:0] == 4'd0 & gradon_right_rom_out[7:4] == 4'd0 & gradon_right_rom_out[11:8] == 4'd0) begin
            red     = fon_rom_out[3:0];
            green   = fon_rom_out[7:4];
            blue    = fon_rom_out[11:8];
          end else begin
            red     = gradon_right_rom_out[3:0];
            green   = gradon_right_rom_out[7:4];
            blue    = gradon_right_rom_out[11:8];
          end
        end
      end else if (object_draw == 5'd2) begin
        if(hero1_rom_out[3:0] == 4'd0 & hero1_rom_out[7:4] == 4'd0 & hero1_rom_out[11:8] == 4'd0) begin
          red     = fon_rom_out[3:0];
          green   = fon_rom_out[7:4];
          blue    = fon_rom_out[11:8];
        end else begin
            red     = hero1_rom_out[3:0];
            green   = hero1_rom_out[7:4];
            blue    = hero1_rom_out[11:8];
        end
      end else begin
          red     = fon_rom_out[3:0];
          green   = fon_rom_out[7:4];
          blue    = fon_rom_out[11:8];
      end
      

    end
  end

  // assign  red     = object_draw ? ( ~sber_logo_active ? 4'hf : sber_logo_rom_out[3:0]  ) : (SW[0] ? 4'h8 : 4'h0);
  // assign  green   = object_draw ? ( ~sber_logo_active ? 4'hf : sber_logo_rom_out[7:4]  ) : (SW[1] ? 4'h8 : 4'h0);
  // assign  blue    = object_draw ? ( ~sber_logo_active ? 4'hf : sber_logo_rom_out[11:8] ) : (SW[2] ? 4'h8 : 4'h0);
//____________________________________________________________________________//
endmodule