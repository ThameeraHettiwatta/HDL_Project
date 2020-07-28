----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/20/2020 08:07:57 PM
-- Design Name: 
-- Module Name: padding - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity padding is generic (
     pixel_depth: integer := 8;                                                         --bit depth of an individual pixel
     input_width : integer := 25;                                                        --width of input image in pixels
     address_width : integer := 10);  
 
  Port (   input_img : in STD_LOGIC_VECTOR (pixel_depth-1 downto 0);                    -- data bus for incoming image (input ram)
           output_img : out STD_LOGIC_VECTOR (pixel_depth-1 downto 0);                  -- data bus for output image after convolution (output ram)
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_in : in STD_LOGIC;                                                    --enable convolve module
           enable_out : out STD_LOGIC;                                                  --enable the output of the module (indicate that convolution is complete)
           input_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);                         --enable writing values to input ram
           output_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);                        --enable writing values to output ram
           input_img_address : out STD_LOGIC_VECTOR (address_width-1 downto 0);         --address for reading values from input ram
           output_img_address : out STD_LOGIC_VECTOR (address_width-1 downto 0));       --address for writing values to output ram
           
end padding;

architecture Behavioral of padding is

begin

process (clock, input_img, reset, enable_in)

    --define constants and variables used for padding process
    constant input_img_size : integer := input_width * input_width;                     --size of input image in pixels
    constant output_width : integer := input_width +2;                                  --width of output image in pixels
    constant output_img_size : integer := output_width * output_width;                  --size of output image in pixels
    variable output_pixel_counter : integer := 0;                                       --used for stepping through each pixel in output image (0 -> output_img_size)
    variable pad_x_index : integer := 0;                                                --horizontal index of output image pixel
    variable pad_y_index : integer := 0;                                                --vertical index of output image pixel
    variable img_x_index : integer := 0;                                                --horizontal index of output image pixel
    variable img_y_index : integer := 0;                                                --vertical index of output image pixel
    variable read_delay : integer := 3;                                                 --ram read delay counter
    variable write_delay : integer := 3;                                                --ram write delay counter
    
    begin
    
    --reset to initial state
        if (reset = '1') then
            output_pixel_counter := 0;
            read_delay := 0;
            write_delay := 0;
            enable_out <= '0';
            input_img_enable <= "0";
            output_img_enable <= "0";
            input_img_address <= "0000000000";
            output_img_address <= "0000000000";
                    
        elsif rising_edge(clock) then
            if enable_in = '1' then
            
                 --if all pixels have been processed, finish output
                 if (output_pixel_counter = output_img_size) then
                    enable_out <= '1';
                 end if; 
                             
                 output_img_enable <= "0";            
                 
                 --read a value from the image
                 pad_x_index := output_pixel_counter mod output_width;
                 pad_y_index := output_pixel_counter / output_width;
                 
                 
                 if (pad_x_index = 0) then 
                    img_x_index := 0;
                                     
                 elsif (pad_x_index > 0 and pad_x_index < (output_width - 1)) then
                    img_x_index := pad_x_index - 1;
                 end if;
                 
                 
                 if (pad_y_index = 0) then
                    img_y_index := 0;
                                     
                 elsif (pad_y_index > 0 and pad_y_index < (output_width - 1)) then
                    img_y_index := pad_y_index - 1;
                 end if;      
                 
                 
                 if (write_delay = 0) then 
                     read_delay := 4;       
                     input_img_address <= std_logic_vector(to_unsigned((input_width*img_y_index) + img_x_index, address_width));
                     -- input_img_enable <= "0"; no need to disable since its never enabled 
                 end if;
                  
                              
                     
                 if (read_delay = 0) then
                     write_delay := 4;   
                     output_img_address <= std_logic_vector(to_unsigned(output_pixel_counter, address_width));                 
                     output_img <= input_img;
                     output_img_enable <= "1";
                     output_pixel_counter := output_pixel_counter + 1;
                 end if;
                        
                     
                 read_delay := read_delay - 1;
                 write_delay := write_delay - 1;
                 
             end if;
        end if;
    end process;
end Behavioral;
