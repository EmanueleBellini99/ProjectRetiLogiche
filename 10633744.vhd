----------------------------------------------------------------------------------
-- Company: Politecnico di Milano
-- Engineer: Emanuele Bellini
-- 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: project_reti_logiche
-- Target Devices: FPGA xc7a200tfbg484-1
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
port (
i_clk : in std_logic;
i_rst : in std_logic;
i_start : in std_logic;
i_data : in std_logic_vector(7 downto 0);
o_address : out std_logic_vector(15 downto 0);
o_done : out std_logic;
o_en : out std_logic;
o_we : out std_logic;
o_data : out std_logic_vector (7 downto 0)
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    signal reg_col : STD_LOGIC_VECTOR (7 downto 0);
    signal min_pixel, max_pixel, read_pixel : std_logic_vector(7 downto 0);
    signal reg_row : STD_LOGIC_VECTOR (7 downto 0);
    signal sum : STD_LOGIC_VECTOR(15 downto 0);
    signal save_address, address_reg_minmax, eq_pixel : std_logic_vector(15 downto 0);
    signal shift, delta, i: integer range 0 to 255;
    signal count : integer range 0 to 65535;
    
    signal o_done_next, o_en_next, o_we_next : std_logic;
    signal o_data_next : std_logic_vector(7 downto 0);
    signal reg_col_next : STD_LOGIC_VECTOR (7 downto 0);
    signal min_pixel_next, max_pixel_next, read_pixel_next : std_logic_vector(7 downto 0);
    signal reg_row_next : STD_LOGIC_VECTOR (7 downto 0);
    signal sum_next : STD_LOGIC_VECTOR(15 downto 0);
    signal o_address_next : std_logic_vector(15 downto 0);
    signal save_address_next, address_reg_minmax_next, eq_pixel_next : std_logic_vector(15 downto 0);
    signal shift_next, delta_next, i_next: integer range 0 to 255;
    signal count_next : integer range 0 to 65535;
    
    type S is (START, READ_COL, MIDDLE_STATE, READ_ROW, COUNT_PIXEL, KEEP_COUNTING, ADDRESS_STATE, MIN_MAX,
     DELTA_STATE, FIND_SHIFT, ADDRESS_STATE2, READ, BEFORE_SHIFT, SHIFT_STATE, CHECK_MAXIMUM, ADDRESS_UPDATE,
      EQ_STATE,ADDRESS_UPDATE2, WAIT_STATE, WAIT_STATE2, DONE_STATE);
    signal cur_state, next_state : S; 

    
begin
process(i_clk, i_rst)
    begin
    
        if(i_rst = '1') then
            o_we <= '0';
            o_address <= "0000000000000000";
            reg_col <= "00000000";
            sum <= "0000000000000000";
            reg_row <= "00000000";
            shift <= 0;
            delta <= 0;
            i <= 0;
            count <= 0;
            save_address <= "0000000000000010";
            address_reg_minmax <= "0000000000000010";
            eq_pixel <= "0000000000000000";
            min_pixel <= "00000000";
            max_pixel <= "00000000";
            read_pixel <= "00000000";
            cur_state <= START;
            
        
            
        elsif (i_clk'event and i_clk = '0') then
            o_done <= o_done_next;
            o_en <= o_en_next;
            o_we <= o_we_next;
            o_data <= o_data_next;
            o_address <= o_address_next;
            
            reg_col <= reg_col_next;
            sum <= sum_next;
            reg_row <= reg_row_next;
            shift <= shift_next;
            delta <= delta_next;
            i <= i_next;
            count <= count_next;
            save_address <= save_address_next;
            address_reg_minmax <= address_reg_minmax_next;
            eq_pixel <= eq_pixel_next;
            min_pixel <= min_pixel_next;
            max_pixel <= max_pixel_next;
            read_pixel <= read_pixel_next;
            
            cur_state <= next_state;
           
        end if;
    end process;

process(i_start, cur_state)
    begin
        o_done_next <= '0';
        o_en_next <= '1';
        o_we_next <= '0';
        o_data_next <= "00000000";
        o_address_next <= "0000000000000000";
        next_state <= cur_state;
        
        reg_col_next <= reg_col;
        sum_next <= sum;
        reg_row_next <= reg_row;
        shift_next <= shift;
        delta_next <= delta;
        i_next <= i;
        count_next <= count;
        save_address_next <= save_address;
        address_reg_minmax_next <= address_reg_minmax;
        eq_pixel_next <= eq_pixel;
        min_pixel_next <= min_pixel;
        max_pixel_next <= max_pixel;
        read_pixel_next <= read_pixel;
        
         
    case cur_state is    
    
        when START =>
            if( i_start = '1' ) then
            
                o_address_next <= "0000000000000000";
                reg_col_next <= "00000000";
                sum_next <= "0000000000000000";
                reg_row_next <= "00000000";
                shift_next <= 0;
                delta_next <= 0;
                i_next <= 0;
                count_next <= 0;
                save_address_next <= "0000000000000010";
                address_reg_minmax_next <= "0000000000000010";
                eq_pixel_next <= "0000000000000000";
                min_pixel_next <= "00000000";
                max_pixel_next <= "00000000";
                read_pixel_next <= "00000000";
                o_en_next <= '1';
                next_state <= READ_COL;
            end if;
            
            
        when READ_COL =>
            reg_col_next <= i_data ;
            o_address_next <= "0000000000000001";
            o_en_next <= '1';
            next_state <= MIDDLE_STATE;
            
            
        when MIDDLE_STATE =>
            if( reg_col_next = "00000000" ) then
                o_done_next <= '1';
                next_state <= DONE_STATE;
            else
                o_address_next <= "0000000000000001";
                o_en_next <= '1';
                next_state <= READ_ROW;
            end if;
            
            
        when READ_ROW =>
            reg_row_next <= i_data;
            o_address_next <= "0000000000000010";
            o_en_next <= '1';
            next_state <= COUNT_PIXEL;


        when COUNT_PIXEL =>
            if( reg_row_next = "00000000" ) then
                o_done_next <= '1';
                next_state <= DONE_STATE;
            else
                sum_next <= sum + ("00000000"&reg_col_next);
                if( i_next<(conv_integer(reg_row_next)-1) ) then
                    o_en_next <= '1';
                    o_address_next <= "0000000000000010";
                    next_state <= KEEP_COUNTING;
                else               
                    min_pixel_next <= "11111111";
                    max_pixel_next <= "00000000";
                    address_reg_minmax_next <= "0000000000000010";
                    o_address_next <= "0000000000000010";
                    o_en_next <= '1';
                    next_state <= ADDRESS_STATE;
                end if;
            end if;
            
        
        when KEEP_COUNTING =>
            i_next <= i + 1;
            o_en_next <= '1';
            o_address_next <= "0000000000000010";
            next_state <= COUNT_PIXEL;
            
        
        when ADDRESS_STATE =>
            count_next <= count + 1;
            address_reg_minmax_next <= address_reg_minmax + "0000000000000001";
            o_address_next <= address_reg_minmax;
            o_en_next <= '1';
            next_state <= MIN_MAX;
        
        
        when MIN_MAX =>
            if( i_data < min_pixel ) then
                min_pixel_next <= i_data;
            end if;
            if( i_data > max_pixel ) then
                max_pixel_next <= i_data;
            end if;
            if( count_next = (conv_integer(sum_next)) ) then
                o_address_next <= "0000000000000010";
                next_state <= DELTA_STATE;
            else
                o_address_next <= address_reg_minmax_next;
                next_state <= ADDRESS_STATE;
            end if;
            
            
        when DELTA_STATE =>
            count_next <= 0;
            delta_next <= ( conv_integer(max_pixel_next) - conv_integer(min_pixel_next) );
            o_address_next <= "0000000000000010";
            next_state <= FIND_SHIFT;
            
            
        when FIND_SHIFT =>
            if( delta_next = 0 ) then
                shift_next <= 8;
            elsif( delta_next >= 1 and delta_next <= 2 ) then
                shift_next <= 7;
            elsif( delta_next >= 3 and delta_next <= 6 ) then
                shift_next <= 6;
            elsif( delta_next >= 7 and delta_next <= 14 ) then
                shift_next <= 5;     
            elsif( delta_next >= 15 and delta_next <= 30 ) then
                shift_next <= 4;
            elsif( delta_next >= 31 and delta_next <= 62 ) then
                shift_next <= 3;    
            elsif( delta_next >= 63 and delta_next <= 126 ) then
                shift_next <= 2;    
            elsif( delta_next >= 127 and delta_next <= 254 ) then
                shift_next <= 1;
            elsif( delta_next = 255 ) then
                shift_next <= 0;
            end if;
            o_en_next <= '1';
            o_address_next <= save_address_next;
            next_state <= ADDRESS_STATE2;
        

        when ADDRESS_STATE2 =>
            o_address_next <= save_address_next;
            o_en_next <= '1';
            next_state <= READ;
            
            
        when READ =>
            o_address_next <= save_address_next;
            read_pixel_next <= i_data;
            next_state <= BEFORE_SHIFT;
            
            
        when BEFORE_SHIFT =>        
            eq_pixel_next <= ("00000000"&(read_pixel_next - min_pixel_next));
            o_address_next <= save_address_next;
            next_state <= SHIFT_STATE;
        
        
        when SHIFT_STATE =>
            eq_pixel_next <= std_logic_vector(shift_left(unsigned(eq_pixel),shift_next));
            o_address_next <= save_address_next + sum_next;
            count_next <= count + 1;
            next_state <= CHECK_MAXIMUM;
            
            
        when CHECK_MAXIMUM =>
            if( eq_pixel > "0000000011111111" ) then
                eq_pixel_next <= "0000000011111111";
            end if;        
            o_en_next <= '1';
            o_address_next <= save_address_next + sum_next;
            next_state <= ADDRESS_UPDATE;
            
            
        when ADDRESS_UPDATE =>
            o_we_next <= '1';
            o_en_next <= '1';
            o_address_next <= save_address_next + sum_next;
            next_state <= EQ_STATE;
            
            
        when EQ_STATE =>
            o_we_next <= '1';
            o_data_next <= eq_pixel_next(7 downto 0);
            o_address_next <= save_address_next + sum_next;
            if( count_next = conv_integer(sum_next) ) then
                o_done_next <= '1';
                next_state <= DONE_STATE;
            else
                next_state <= ADDRESS_UPDATE2;
            end if;
            
            
        when ADDRESS_UPDATE2 =>
            o_address_next <= save_address_next + sum_next;
            next_state <= WAIT_STATE;
            
        when WAIT_STATE =>
            o_address_next <= save_address_next;
            save_address_next <="0000000000000001" + save_address;
            next_state <= WAIT_STATE2;
            
            
        when WAIT_STATE2 =>
            o_address_next <= save_address_next;      
            next_state <= ADDRESS_STATE2;
            
            
        when DONE_STATE =>
            next_state <= START;
                
   end case;            
   end process;

end Behavioral;
