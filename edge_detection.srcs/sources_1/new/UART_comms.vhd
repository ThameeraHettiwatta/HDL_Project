----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/26/2020 01:11:20 AM
-- Design Name: 
-- Module Name: UART_reciever - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


--uart data receiver module based on text book - FPGA PROTOTYPING BY VHDL EXAMPLES, Pong P. Chu

entity uart_rx is
    generic(
        data_bits: integer := 8;      --  #  d a t a   b i t s  
        stop_bit_ticks: integer := 16   --  #  t i c k s   f o r   s t o p   b i t s  
    );
    Port ( rx : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset: in STD_LOGIC;
           tick : in STD_LOGIC;
           rx_done : out STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0));
end uart_rx;

architecture arch of uart_rx is
    type state_type is (idle, start, data, stop);
    SIGNAL state_reg, state_next: state_type;
    SIGNAL s_reg, s_next: UNSIGNED(3 downto 0);
    SIGNAL n_reg, n_next: UNSIGNED(2 downto 0);
    SIGNAL b_reg, b_next: STD_LOGIC_VECTOR(7 downto 0);
begin
--  FSMD  s t a t e   &  d a t a   r e g i s t e r s  
    process(clk, reset) -- FSMD state and data regs.
    begin
        if (reset = '1') then
            state_reg <= idle;
            s_reg <= (others => '0');
            n_reg <= (others => '0');
            b_reg <= (others => '0');
            --rx_done <= '0';
        --  rx <= '1';
        elsif (clk'event and clk='1') then
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end if;
    end process;
   --  n e x t - s t a t e   l o g i c   &  d a t a   p a t h   f u n c t i o n a l   u n i t s / r o u t i n g
    process (state_reg, s_reg, n_reg, b_reg, tick, rx)
    begin
        state_next <= state_reg;
        s_next <= s_reg;
        n_next <= n_reg;
        b_next <= b_reg;
        rx_done <= '0';
        case state_reg is
        when idle =>
            if (rx = '0') then
            state_next <= start;
            s_next <= (others => '0');
            end if;
        when start =>
            if (tick = '1') then
                if (s_reg = 7) then
                    state_next <= data;
                    s_next <= (others => '0');
                    n_next <= (others => '0');
                else
                    s_next <= s_reg + 1;
                end if;
            end if;
        when data =>
            if (tick = '1') then
                if (s_reg = 15) then
                    s_next <= (others => '0');
                    b_next <= rx & b_reg(7 downto 1);
                    if (n_reg = (data_bits - 1)) then
                        state_next <= stop;
                    else
                        n_next <= n_reg + 1;
                    end if;
                else
                    s_next <= s_reg + 1;
                end if;
            end if;
        when stop =>
            if (tick = '1') then
                if (s_reg = (stop_bit_ticks - 1)) then
                    state_next <= idle;
                    rx_done <= '1';
                else
                    s_next <= s_reg + 1;
                end if;
            end if;
        end case;
    end process;
    data_out <= b_reg; 
    
end arch;