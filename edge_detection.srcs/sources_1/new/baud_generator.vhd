----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/26/2020 12:50:20 PM
-- Design Name: 
-- Module Name: baud_generator - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity baud_generator is
    Port ( clk : in STD_LOGIC;
           enable : out STD_LOGIC;
           rst_n : in STD_LOGIC);
end baud_generator;

architecture Behavioral of baud_generator is

--simple clk divider used to generate ticks at baud rate
--basys3 clk = 100mhz
--clk counter = 100 * 10^6 (2^27)
--921600 samples/sec = 921,600 Hz
--divider = 100,000,000/921,600 = 108.51.

signal time : unsigned (26 downto 0);       --used to store the necessary time interval

begin

baud : PROCESS(clk, rst_n)
BEGIN

if (rst_n = '0') THEN
    time <= to_unsigned(109, 27);
    enable <= '0';
end if;

if rising_edge(clk) THEN
    if (time = to_unsigned(0, 27)) then     --once time limmit is reached, set enable to 1
        enable <= '1';
        time <= to_unsigned(109, 27);
    else
        time <= time - 1;
        enable <= '0';
    end if;
end if;

end process baud;
end Behavioral;