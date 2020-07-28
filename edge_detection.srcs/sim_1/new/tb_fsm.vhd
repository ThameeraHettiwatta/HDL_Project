----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/26/2020 04:37:14 PM
-- Design Name: 
-- Module Name: tb_fsm - Behavioral
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

entity tb_fsm is
--  Port ( );
end tb_fsm;

architecture Behavioral of tb_fsm is    

component fsm is
  Port (   clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           enable_edge_detection_in : in STD_LOGIC;                                                
           edge_detection_done_out : out STD_LOGIC;                                          
           enable_convolve_out : out STD_LOGIC;                                              
           enable_padding_out : out STD_LOGIC;                                               
           convolve_done_in : in STD_LOGIC;                                                  
           padding_done_in : in STD_LOGIC;                                                
           read_enable_uart_out : out STD_LOGIC := '0';                                                    
           write_enable_uart_out : out STD_LOGIC := '0';                                                     
           uart_read_done_in : in STD_LOGIC;                                                  
           uart_write_done_in : in STD_LOGIC );                                                 
end component;

signal clk : STD_LOGIC := '0';
signal rst_n : STD_LOGIC;
signal enable_edge_detection : STD_LOGIC;
signal edge_detection_done : STD_LOGIC;
signal enable_convolve : STD_LOGIC;
signal enable_padding : STD_LOGIC;
signal convolve_done : STD_LOGIC;
signal padding_done : STD_LOGIC;
signal read_enable_uart : STD_LOGIC;                                                      
signal write_enable_uart : STD_LOGIC;                                                     
signal uart_read_done : STD_LOGIC;                                                   
signal uart_write_done : STD_LOGIC;                                                  
           
begin

    fsm1 : fsm
        port map ( clk => clk,
                   rst_n => rst_n,
                   enable_edge_detection_in => enable_edge_detection,
                   edge_detection_done_out => edge_detection_done,
                   enable_convolve_out => enable_convolve,
                   enable_padding_out => enable_padding,
                   convolve_done_in => convolve_done,
                   padding_done_in => padding_done, 
                   read_enable_uart_out => read_enable_uart,
                   write_enable_uart_out => write_enable_uart,
                   uart_read_done_in => uart_read_done,
                   uart_write_done_in => uart_write_done);
    
    clk <= not clk after 5ns;

    stimuli : process 
        begin
            rst_n <= '0';
            padding_done <= '0';
            convolve_done <= '0';
            uart_read_done <= '0';
            uart_write_done <= '0';
            enable_edge_detection <= '0';
            wait for 5ns;
            rst_n <= '1';
            wait for 10ns;
            enable_edge_detection <= '1';
            wait for 30ns;
            uart_read_done <= '1';
            wait for 30ns;
            padding_done <= '1';
            wait for 30ns;
            convolve_done <= '1';
            wait for 30ns;
            uart_write_done <= '1';
            wait for 10ns;
            enable_edge_detection <= '0';
            
            wait;
            
        end process;    

end Behavioral;
