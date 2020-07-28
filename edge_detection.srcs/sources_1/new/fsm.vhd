----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/26/2020 12:26:52 PM
-- Design Name: 
-- Module Name: fsm - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm is  
  Port (   clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           enable_edge_detection_in : in STD_LOGIC;                                         --enable signal of start edge detection process       
           edge_detection_done_out : out STD_LOGIC := '0';                                          --signal to indicate the completion of edge detection process
           enable_convolve_out : out STD_LOGIC := '0';                                                --enable signal of convolve module
           enable_padding_out : out STD_LOGIC := '0';                                                --enable signal of padding module
           convolve_done_in : in STD_LOGIC;                                                  --signal to indicate that convolution is complete
           padding_done_in : in STD_LOGIC;                                                --signal to indicate that padding is complete
           read_enable_uart_out : out STD_LOGIC := '0';                                                      --enable reading from uart
           write_enable_uart_out : out STD_LOGIC := '0';                                                     --enable writing to uart
           uart_read_done_in : in STD_LOGIC;                                                   --indicate reading completion
           uart_write_done_in : in STD_LOGIC );                                                  --indicate writing completion
           
end fsm;

architecture Behavioral of fsm is

type state is (idle, padding, convolve, receiver, transmitter);
signal fsm_state : state;

begin

state_machine : process (clk, enable_edge_detection_in, rst_n, convolve_done_in, padding_done_in, uart_read_done_in, uart_write_done_in)
    begin
        --rst_n to initial state
        if (rst_n = '0') then
            fsm_state <= idle;
            edge_detection_done_out <= '0';
            enable_convolve_out <= '0';
            enable_padding_out <= '0';
            read_enable_uart_out <= '0';
            write_enable_uart_out <= '0';

        elsif rising_edge(clk) then
                case fsm_state is
                    when idle =>
                        edge_detection_done_out <= '0';
                        enable_convolve_out <= '0';
                        enable_padding_out <= '0';  
                        read_enable_uart_out <= '0';
                        write_enable_uart_out <= '0';                           
                        if (enable_edge_detection_in = '1') then
                            read_enable_uart_out <= '1';
                            fsm_state <= receiver; 
                        end if;
                    when receiver =>
                        if(uart_read_done_in = '1') then
                            read_enable_uart_out <= '0';
                            enable_padding_out <= '1';
                            fsm_state <= padding;
                        end if;
                    when padding =>
                        if (padding_done_in = '1') then
                            enable_padding_out <= '0';
                            enable_convolve_out <= '1';
                            fsm_state <= convolve;
                        end if;
                    when convolve =>
                        if (convolve_done_in = '1') then
                            enable_convolve_out <= '0';
                            write_enable_uart_out <= '1';
                            fsm_state <= transmitter;
                        end if;
                    when transmitter =>
                        if (uart_write_done_in = '1') then
                            write_enable_uart_out <= '0';
                            edge_detection_done_out <= '1';
                            fsm_state <= idle;
                        end if;
                    when others =>
                        fsm_state <= idle;                        
                end case;
        end if;
    end process state_machine;
end Behavioral;
