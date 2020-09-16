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
     pixel_depth_g: integer := 8;                                                         --bit depth of an individual pixel
     input_width_g : integer := 27;                                                        --width of input image in pixels
     address_width_g : integer := 10);                                                    --width of memory address (can address upto 2^10 individual pixels)

    Port ( input_img_in : in STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                    -- data bus for incoming image (input ram)
           output_img_out : out STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                  -- data bus for output image after convolution (output ram)
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           enable_in : in STD_LOGIC;                                                    --enable convolve module
           enable_out : out STD_LOGIC;                                                  --enable the output of the module (indicate that convolution is complete)
           input_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                         --enable writing values to input ram
           output_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                        --enable writing values to output ram
           input_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);         --address for reading values from input ram
           output_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0));       --address for writing values to output ram
           
end convolve;

architecture Behavioral of convolve is

begin

convolve_image : process (clk, input_img_in, rst_n, enable_in)

    --note : kernel used for convolution: [[-1, -1, -1] , [-1, 8, -1] , [-1, -1, -1]]
    --note : image normalization not performed since sum of kernel  values = 0
    --note : kernel has negative values so pixel values can be negative (or greater than 255). These have been clipped
    --note : stride is set to 1
    --note : read delay for portA is 3 cycles (1 cycle to update address + 2 cycles delay from IP core), therefore memory read is delayed by 3 cycles
    
    --define constants and variables used for convolution process
    constant input_img_size : integer := input_width_g * input_width_g;                     --size of input image in pixels
    constant output_width : integer := input_width_g -2;                                  --width of output image in pixels
    constant output_img_size : integer := output_width * output_width;                  --size of output image in pixels
    constant kernel_width : integer := 3;                                               --width of kernel used in pixels
    constant kernel_size : integer := kernel_width * kernel_width;                      --size of kernel in pixels
    type int_array is array(0 to kernel_size-1) of integer;                             --integer array type for holding convolution kernel
    -- constant conv_kernel : int_array := (-1,-1,-1,-1,8,-1,-1,-1,-1);                    --values for convolution kernel
    variable output_pixel_counter : integer := 0;                                       --used for stepping through each pixel in output image (0 -> output_img_size)
    variable kernel_pixel_counter : integer := 0;                                       --used for stepping through each value in kernel (0 -> 9)
    variable img_pixel : integer := 0;                                                  --used for storing image pixel value read from ram
    variable conv_sum : integer := 0;                                                   --used for storage of convolution output for one pixel
    variable kernel_x_index : integer := 0;                                             --horizontal index of kernel value
    variable kernel_y_index : integer := 0;                                             --horizontal index of kernel value
    variable img_x_index : integer := 0;                                                --horizontal index of output image pixel
    variable img_y_index : integer := 0;                                                --vertical index of output image pixel
    begin

        --rst_n to initial state
        if (rst_n = '0') then
            output_pixel_counter := 0;
            kernel_pixel_counter := 0;
            enable_out <= '0';
            input_img_enable_out <= "0";
            output_img_enable_out <= "0";
            conv_sum := 0;
            input_img_address_out <= "0000000000";
            output_img_address_out <= "0000000000";
                    
        elsif rising_edge(clk) then
            if enable_in = '1' then
                
                --read a value from the image
                kernel_x_index := kernel_pixel_counter mod kernel_width;
                kernel_y_index := kernel_pixel_counter / kernel_width;
                img_x_index := output_pixel_counter mod output_width;
                img_y_index := output_pixel_counter / output_width;
                input_img_address_out <= std_logic_vector(to_unsigned(((img_y_index + kernel_y_index) * input_width_g) + (img_x_index +kernel_x_index), address_width_g));
                -- input_img_enable_out <= "0"; no need to disable since its never enabled
                img_pixel := to_integer(unsigned(input_img_in));
                
                --read a value from the kernel, multiply and add to the sum
                if (kernel_pixel_counter = 3) then                                                          --restart calculations from zero
                    output_img_enable_out <= "0";                                                           --turn off data writing
                    conv_sum := (img_pixel * (-1) );                                                        --start sum from zero
                else
                    if (kernel_pixel_counter = 7) then
                        conv_sum := conv_sum + (img_pixel * (8) );
                    else
                        conv_sum := conv_sum - img_pixel;
                    end if;
                    --conv_sum := conv_sum + (img_pixel * conv_kernel((kernel_pixel_counter-3)mod kernel_size));
                end if;
                               
                if (kernel_pixel_counter = 2) then                                                          --send pixel value to ram
                    
                    --clip values outside 0 and 255
                    if (conv_sum < 0) then
                        conv_sum := 0;
                    elsif (conv_sum > 255) then
                        conv_sum := 255;
                    end if;
                     
                    --ignore the first iteration, otherwise write output
                    if (output_pixel_counter /= 0) then
                        output_img_address_out <= std_logic_vector(to_unsigned(output_pixel_counter-1, address_width_g));
                        output_img_out <= std_logic_vector(to_unsigned(conv_sum, pixel_depth_g));
                        output_img_enable_out <= "1";
                    end if;
                          
                    --if all pixels have been processed, finish output
                    if (output_pixel_counter = output_img_size) then
                        enable_out <= '1';
                    end if;
                end if;
                
               kernel_pixel_counter := kernel_pixel_counter + 1;                                            --increment kernel counter
                
                if (kernel_pixel_counter = kernel_size) then                                               
                    kernel_pixel_counter := 0;                                                              --reset kernel_counter
                    output_pixel_counter := output_pixel_counter + 1;                                       --increment output pixel counter
                end if;

            end if;
        end if;

    end process convolve_image;

end Behavioral;
