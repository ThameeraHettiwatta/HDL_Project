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
    Port ( Clock : in STD_LOGIC;
           enable : out STD_LOGIC;
           reset : in STD_LOGIC);
end baud_generator;

architecture Behavioral of baud_generator is

--simple clock divider used to generate ticks at baud rate
--basys3 clock = 100mhz
--clock counter = 100 * 10^6 (2^27)
--921600 samples/sec = 921,600 Hz
--divider = 100,000,000/921,600 = 108.51.

signal time : unsigned (26 downto 0);       --used to store the necessary time interval

begin

PROCESS(Clock, reset)
BEGIN

if (reset = '1') THEN
    time <= to_unsigned(109, 27);
    enable <= '0';
end if;

if rising_edge(Clock) THEN
    if (time = to_unsigned(0, 27)) then
        enable <= '1';
        time <= to_unsigned(109, 27);
    else
        time <= time - 1;
        enable <= '0';
    end if;
end if;

end process;
end Behavioral;