----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/24/2020 11:20:38 AM
-- Design Name: 
-- Module Name: ram_to_text - Behavioral
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

entity ram_to_text is
    Port (data_in : in STD_LOGIC_VECTOR(7 DOWNTO 0);
          write_enable : in STD_LOGIC_VECTOR (0 downto 0) :="0";
          data_out : out STD_LOGIC_VECTOR(7 DOWNTO 0) );
end ram_to_text;

architecture Behavioral of ram_to_text is

begin
    process ( write_enable, data_in)
        begin
            if ( write_enable 'event and write_enable = "1") then
                data_out<=data_in;
            end if;
    end process;
end Behavioral;
