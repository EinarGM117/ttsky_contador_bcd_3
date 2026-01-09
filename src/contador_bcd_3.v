module tt_um_contador_bcd (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    assign uio_oe = 8'hFF;
    assign uio_out[7:4] = 4'h0;
    assign uo_out[7] = 1'b0;

    localparam FREQ_BASE = 50_000_000;
    localparam MAX_TICK  = FREQ_BASE / 4; 

    reg [31:0] prescaler;
    reg        pulso_4hz;
    reg [7:0]  cnt_binario;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prescaler <= 0;
            pulso_4hz <= 0;
        end else begin
            pulso_4hz <= 0;
            if (prescaler < MAX_TICK - 1) begin
                prescaler <= prescaler + 1;
            end else begin
                prescaler <= 0;
                pulso_4hz <= 1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            cnt_binario <= 8'd0;
        else if (pulso_4hz) 
            cnt_binario <= cnt_binario + 1'b1;
    end

    reg [3:0] bcd_cent;
    reg [3:0] bcd_dec;
    reg [3:0] bcd_uni;

    always @(*) begin
        bcd_cent = cnt_binario / 100;
        bcd_dec  = (cnt_binario % 100) / 10;
        bcd_uni  = cnt_binario % 10;
    end

    reg [19:0] scan_timer;
    wire [1:0] sel_activo;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) scan_timer <= 0;
        else        scan_timer <= scan_timer + 1;
    end

    assign sel_activo = scan_timer[19:18];

    reg [3:0] nibble_out;
    reg [3:0] anodos_temp;

    always @(*) begin
        case (sel_activo)
            2'b00: begin
                anodos_temp = 4'b1110;
                nibble_out  = bcd_uni;
            end
            2'b01: begin
                anodos_temp = 4'b1101;
                nibble_out  = bcd_dec;
            end
            2'b10: begin
                anodos_temp = 4'b1011;
                nibble_out  = bcd_cent;
            end
            default: begin
                anodos_temp = 4'b1111;
                nibble_out  = 4'h0;
            end
        endcase
    end

    assign uio_out[3:0] = anodos_temp;

    reg [6:0] seg_temp;

    always @(*) begin
        case (nibble_out)
            4'h0: seg_temp = 7'h40;
            4'h1: seg_temp = 7'h79;
            4'h2: seg_temp = 7'h24;
            4'h3: seg_temp = 7'h30;
            4'h4: seg_temp = 7'h19;
            4'h5: seg_temp = 7'h12;
            4'h6: seg_temp = 7'h02;
            4'h7: seg_temp = 7'h78;
            4'h8: seg_temp = 7'h00;
            4'h9: seg_temp = 7'h10;
            default: seg_temp = 7'h7F;
        endcase
    end

    assign uo_out[6:0] = seg_temp;

endmodule