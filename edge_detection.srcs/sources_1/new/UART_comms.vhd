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
        data_bits: integer := 8;      --  # data bits  
        stop_bit_ticks: integer := 16   --  # ticks for stop bits  
    );
    Port ( rx : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst_n: in STD_LOGIC;
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
--  FSMD state & data  egisters 
    process(clk, rst_n) 
    begin
        if (rst_n = '1') then
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
   -- next-state logic 
    process (state_reg, s_reg, n_reg, b_reg, tick, rx)
    begin
        state_next <= state_reg;
        s_next <= s_reg;
        n_next <= n_reg;
        b_next <= b_reg;
        rx_done <= '0';
        case state_reg is
        when idle =>                                                --idle state, keep checking for
            if (rx = '0') then                                      --start of commmunication
            state_next <= start;
            s_next <= (others => '0');
            end if;
        when start =>                                               --assert whether 7 ticks are received
            if (tick = '1') then                                    --to indicate start of transmission
                if (s_reg = 7) then
                    state_next <= data;
                    s_next <= (others => '0');
                    n_next <= (others => '0');
                else
                    s_next <= s_reg + 1;
                end if;
            end if;
        when data =>                                                --begin receiving data by reading incoming
            if (tick = '1') then                                    --bits into shift register
                if (s_reg = 15) then
                    s_next <= (others => '0');
                    b_next <= rx & b_reg(7 downto 1);
                    if (n_reg = (data_bits - 1)) then               --check for the end of data
                        state_next <= stop;
                    else
                        n_next <= n_reg + 1;
                    end if;
                else
                    s_next <= s_reg + 1;
                end if;
            end if;
        when stop =>                                                --assert the stop signal and move
            if (tick = '1') then                                    --to idle state
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