----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.07.2020 18:06:06
-- Design Name: 
-- Module Name: convolve - Behavioral
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

entity convolve is generic (
     pixel_depth: integer := 8;                                                         --bit depth of an individual pixel
     input_width : integer := 7;                                                        --width of input image in pixels
     address_width : integer := 10);                                                    --width of memory address (can address upto 2^10 individual pixels)

    Port ( input_img : in STD_LOGIC_VECTOR (pixel_depth-1 downto 0);                    -- data bus for incoming image (input ram)
           output_img : out STD_LOGIC_VECTOR (pixel_depth-1 downto 0);                  -- data bus for output image after convolution (output ram)
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_in : in STD_LOGIC;                                                    --enable convolve module
           enable_out : out STD_LOGIC;                                                  --enable the output of the module (indicate that convolution is complete)
           input_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);                         --enable writing values to input ram
           output_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);                        --enable writing values to output ram
           input_img_address : out STD_LOGIC_VECTOR (address_width-1 downto 0);         --address for reading values from input ram
           output_img_address : out STD_LOGIC_VECTOR (address_width-1 downto 0));       --address for writing values to output ram
           
end convolve;

architecture Behavioral of convolve is

begin

process (clock, input_img, reset, enable_in)

    --define constants and variables used for convolution process
    --note : kernel used for convolution: [[-1, -1, -1] , [-1, 8, -1] , [-1, -1, -1]]
    --note : image normalization not performed since sum of kernel  values = 0
    --note : TODO kernel has negative values so pixel values can be negative (or greater than 255). These need to be clipped? or auto clipped? can be done with resize?
    --note : stride is set to 1
    constant input_img_size : integer := input_width * input_width;                     --size of input image in pixels
    constant output_width : integer := input_width -2;                                  --width of output image in pixels
    constant output_img_size : integer := output_width * output_width;                  --size of output image in pixels
    constant kernel_width : integer := 3;                                               --width of kernel used in pixels
    constant kernel_size : integer := kernel_width * kernel_width;                      --size of kernel in pixels
    type int_array is array(0 to kernel_size-1) of integer;                              --integer array type for holding convolution kernel
    constant conv_kernel : int_array := (-1,-1,-1,-1,8,-1,-1,-1,-1);                    --values for convolution kernel
    variable output_pixel_counter : integer := 0;                                       --used for stepping through each pixel in output image (0 -> output_img_size)
    variable kernel_pixel_counter : integer := 0;                                       --used for stepping through each value in kernel (0 -> 9)
    variable img_pixel : integer := 0;                                                  --used for storing image pixel value read from ram
    variable conv_sum : integer := 0;                                                   --used for storage of convolution output for one pixel
    variable kernel_x_index : integer := 0;                                             --horizontal index of kernel value
    variable kernel_y_index : integer := 0;                                             --horizontal index of kernel value
    variable img_x_index : integer := 0;                                                --horizontal index of output image pixel
    variable img_y_index : integer := 0;                                                --vertical index of output image pixel

    begin

        --reset to initial state
        if (reset = '0') then
            output_pixel_counter := 0;
            kernel_pixel_counter := 0;
            enable_out <= '0';
            input_img_enable <= "0";
            output_img_enable <= "0";
            conv_sum := 0;
        
        elsif rising_edge(clock) then
            if enable_in = '1' then
                
                --read a value from the image
                kernel_x_index := kernel_pixel_counter mod kernel_width;
                kernel_y_index := kernel_pixel_counter / kernel_width;
                img_x_index := output_pixel_counter mod output_width;
                img_y_index := output_pixel_counter / output_width;
                input_img_address <= std_logic_vector(to_unsigned(((img_y_index + kernel_y_index -1) * input_width) + (img_x_index +kernel_x_index -1), address_width));
                -- input_img_enable <= "0"; no need to disable since its never enabled?
                img_pixel := to_integer(unsigned(input_img));
                
                --read a value from the kernel, multiply and add to the sum
                if (kernel_pixel_counter = 0) then
                    output_img_enable <= "0";                                           --turn off data writing
                    conv_sum := (img_pixel * conv_kernel(kernel_pixel_counter));        --start sum from zero
                else
                    conv_sum := conv_sum + (img_pixel * conv_kernel(kernel_pixel_counter));
                end if;
                
                --increment kernel counter
                kernel_pixel_counter := kernel_pixel_counter + 1;
                
                --if end of the kernel is reached, write to output
                if (kernel_pixel_counter = kernel_size) then
                    output_img_address <= std_logic_vector(to_unsigned(output_pixel_counter, address_width));
                    output_img <= std_logic_vector(to_unsigned(conv_sum, pixel_depth));
                    output_img_enable <= "1";
                    kernel_pixel_counter := 0;                                        --reset kernel_counter
                    
                    --increment output pixel counter
                    output_pixel_counter := output_pixel_counter + 1;
                    
                    --if all pixels have been processed, finish output
                    if (output_pixel_counter = output_img_size) then
                        enable_out <= '1';
                    end if;
                
                end if;
            end if;
        end if;

    end process;

end Behavioral;
