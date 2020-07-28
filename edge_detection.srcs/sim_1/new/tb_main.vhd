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
  Port ( clock : in STD_LOGIC;
         reset : in STD_LOGIC;
         rx : in STD_LOGIC;
         tx : out STD_LOGIC;
         enable_edge_detection : in STD_LOGIC;                                               
         edge_detection_done : out STD_LOGIC := '0');                                  
end component;

signal clock : STD_LOGIC:= '1';
signal reset :STD_LOGIC;
signal enable_edge_detection : STD_LOGIC;
signal edge_detection_done : STD_LOGIC;
signal rx : STD_LOGIC;
signal tx : STD_LOGIC;

begin

main1 : main
    port map(clock => clock,
             reset => reset,
             rx => rx,
             tx => tx,
             enable_edge_detection => enable_edge_detection,
             edge_detection_done => edge_detection_done);

    clock <= not clock after 5ns;
    
    stimuli : process 
        begin
            reset <= '1';
            enable_edge_detection <= '0';
            wait for 5ns;
            reset <= '0';
            wait for 10ns;
            enable_edge_detection <= '1';
            wait for 10ns;
            rx <= '1';
            wait for 10ns;
            enable_edge_detection <= '0';
            wait;
        end process;

end Behavioral;
