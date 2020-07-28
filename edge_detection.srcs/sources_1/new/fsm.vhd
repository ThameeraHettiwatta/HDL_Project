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
  Port (   clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_edge_detection : in STD_LOGIC;                                         --enable signal of start edge detection process       
           edge_detection_done : out STD_LOGIC := '0';                                          --signal to indicate the completion of edge detection process
           enable_convolve : out STD_LOGIC := '0';                                                --enable signal of convolve module
           enable_padding : out STD_LOGIC := '0';                                                --enable signal of padding module
           convolve_done : in STD_LOGIC;                                                  --signal to indicate that convolution is complete
           padding_done : in STD_LOGIC;                                                --signal to indicate that padding is complete
           read_enable_uart : out STD_LOGIC := '0';                                                      --enable reading from uart
           write_enable_uart : out STD_LOGIC := '0';                                                     --enable writing to uart
           uart_read_done : in STD_LOGIC;                                                   --indicate reading completion
           uart_write_done : in STD_LOGIC );                                                  --indicate writing completion
           
end fsm;

architecture Behavioral of fsm is

type state is (idle, padding, convolve, receiver, transmitter);
signal fsm_state : state;

begin

process (clock, enable_edge_detection, reset, convolve_done, padding_done, uart_read_done, uart_write_done)
    begin
        --reset to initial state
        if (reset = '1') then
            fsm_state <= idle;
            edge_detection_done <= '0';
            enable_convolve <= '0';
            enable_padding <= '0';
            read_enable_uart <= '0';
            write_enable_uart <= '0';

        elsif rising_edge(clock) then
                case fsm_state is
                    when idle =>
                        edge_detection_done <= '0';
                        enable_convolve <= '0';
                        enable_padding <= '0';  
                        read_enable_uart <= '0';
                        write_enable_uart <= '0';                           
                        if (enable_edge_detection = '1') then
                            read_enable_uart <= '1';
                            fsm_state <= receiver; 
                        end if;
                    when receiver =>
                        if(uart_read_done = '1') then
                            read_enable_uart <= '0';
                            enable_padding <= '1';
                            fsm_state <= padding;
                        end if;
                    when padding =>
                        if (padding_done = '1') then
                            enable_padding <= '0';
                            enable_convolve <= '1';
                            fsm_state <= convolve;
                        end if;
                    when convolve =>
                        if (convolve_done = '1') then
                            enable_convolve <= '0';
                            write_enable_uart <= '1';
                            fsm_state <= transmitter;
                        end if;
                    when transmitter =>
                        if (uart_write_done = '1') then
                            write_enable_uart <= '0';
                            edge_detection_done <= '1';
                            fsm_state <= idle;
                        end if;
                    when others =>
                        fsm_state <= idle;                        
                end case;
        end if;
    end process;
end Behavioral;
