module contador_bcd_3 (
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

    localparam FRECUENCIA_BASE = 50_000_000;
    localparam CUENTA_MAXIMA   = FRECUENCIA_BASE / 4; 

    logic [31:0] divisor_frecuencia;
    logic        pulso_habilitacion;
    logic [7:0]  cuenta_principal;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            divisor_frecuencia <= 0;
            pulso_habilitacion <= 0;
        end else begin
            pulso_habilitacion <= 0;
            if (divisor_frecuencia < CUENTA_MAXIMA - 1) begin
                divisor_frecuencia <= divisor_frecuencia + 1;
            end else begin
                divisor_frecuencia <= 0;
                pulso_habilitacion <= 1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            cuenta_principal <= 8'd0;
        else if (pulso_habilitacion) 
            cuenta_principal <= cuenta_principal + 1'b1;
    end

    logic [3:0] val_centenas;
    logic [3:0] val_decenas;
    logic [3:0] val_unidades;

    always_comb begin
        val_centenas = cuenta_principal / 100;
        val_decenas  = (cuenta_principal % 100) / 10;
        val_unidades = cuenta_principal % 10;
    end

    logic [19:0] contador_barrido;
    logic [1:0]  selector_display;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) contador_barrido <= 0;
        else        contador_barrido <= contador_barrido + 1;
    end

    assign selector_display = contador_barrido[19:18];

    logic [3:0] cifra_activa;

    always_comb begin
        case (selector_display)
            2'b00: begin
                uio_out[3:0] = 4'b1110;
                cifra_activa = val_unidades;
            end
            2'b01: begin
                uio_out[3:0] = 4'b1101;
                cifra_activa = val_decenas;
            end
            2'b10: begin
                uio_out[3:0] = 4'b1011;
                cifra_activa = val_centenas;
            end
            default: begin
                uio_out[3:0] = 4'b1111;
                cifra_activa = 4'h0;
            end
        endcase
    end

    always_comb begin
        case (cifra_activa)
            4'h0: uo_out[6:0] = 7'h40;
            4'h1: uo_out[6:0] = 7'h79;
            4'h2: uo_out[6:0] = 7'h24;
            4'h3: uo_out[6:0] = 7'h30;
            4'h4: uo_out[6:0] = 7'h19;
            4'h5: uo_out[6:0] = 7'h12;
            4'h6: uo_out[6:0] = 7'h02;
            4'h7: uo_out[6:0] = 7'h78;
            4'h8: uo_out[6:0] = 7'h00;
            4'h9: uo_out[6:0] = 7'h10;
            default: uo_out[6:0] = 7'h7F;
        endcase
    end

endmodule