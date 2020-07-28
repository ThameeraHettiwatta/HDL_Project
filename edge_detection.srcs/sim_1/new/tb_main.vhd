----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/27/2020 01:30:47 AM
-- Design Name: 
-- Module Name: tb_main - Behavioral
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

entity tb_main is
--  Port ( );
end tb_main;

architecture Behavioral of tb_main is

component main is
  Port ( clk : in STD_LOGIC;
         rst_n : in STD_LOGIC;
         rx_in : in STD_LOGIC;
         tx_out : out STD_LOGIC;
         enable_edge_detection_in : in STD_LOGIC;                                               
         edge_detection_done_out : out STD_LOGIC := '0');                                  
end component;

signal clk : STD_LOGIC:= '1';
signal rst_n :STD_LOGIC;
signal enable_edge_detection_in : STD_LOGIC;
signal edge_detection_done_out : STD_LOGIC;
signal rx : STD_LOGIC;
signal tx : STD_LOGIC;

begin

main1 : main
    port map(clk => clk,
             rst_n => rst_n,
             rx_in => rx,
             tx_out => tx,
             enable_edge_detection_in => enable_edge_detection_in,
             edge_detection_done_out => edge_detection_done_out);

    clk <= not clk after 5ns;
    
    stimuli : process 
        begin
            rst_n <= '0';
            enable_edge_detection_in <= '0';
            wait for 5ns;
            rst_n <= '1';
            wait for 10ns;
            enable_edge_detection_in <= '1';
            wait for 10ns;
            rx <= '1';
            wait for 10ns;
            enable_edge_detection_in <= '0';
            wait;
        end process;

end Behavioral;
