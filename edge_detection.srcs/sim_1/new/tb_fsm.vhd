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
  Port (   clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_edge_detection : in STD_LOGIC;                                         --enable signal of start edge detection process       
           edge_detection_done : out STD_LOGIC;                                          --signal to indicate the completion of edge detection process
           enable_convolve : out STD_LOGIC;                                                --enable signal of convolve module
           enable_padding : out STD_LOGIC;                                                --enable signal of padding module
           convolve_done : in STD_LOGIC;                                                  --signal to indicate that convolution is complete
           padding_done : in STD_LOGIC );                                                --signal to indicate that padding is complete
end component;

signal clock : STD_LOGIC := '0';
signal reset : STD_LOGIC;
signal enable_edge_detection : STD_LOGIC;
signal edge_detection_done : STD_LOGIC;
signal enable_convolve : STD_LOGIC;
signal enable_padding : STD_LOGIC;
signal convolve_done : STD_LOGIC;
signal padding_done : STD_LOGIC;

begin

    fsm1 : fsm
        port map ( clock => clock,
                   reset => reset,
                   enable_edge_detection => enable_edge_detection,
                   edge_detection_done => edge_detection_done,
                   enable_convolve => enable_convolve,
                   enable_padding => enable_padding,
                   convolve_done => convolve_done,
                   padding_done => padding_done );
    
    clock <= not clock after 5ns;

    stimuli : process 
        begin
            reset <= '1';
            padding_done <= '0';
            convolve_done <= '0';
            enable_edge_detection <= '0';
            wait for 5ns;
            reset <= '0';
            wait for 10ns;
            enable_edge_detection <= '1';
            wait for 30ns;
            padding_done <= '1';
            wait for 30ns;
            convolve_done <= '1';
            wait for 10ns;
            enable_edge_detection <= '0';
            
            wait;
            
        end process;    

end Behavioral;
