----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/27/2020 12:20:17 AM
-- Design Name: 
-- Module Name: main - Behavioral
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

entity main is
  Port ( clk : in STD_LOGIC;
         rst_n : in STD_LOGIC;
         enable_edge_detection_in : in STD_LOGIC;                                        --enable signal of start edge detection process       
         edge_detection_done_out : out STD_LOGIC := '0';                                  --signal to indicate the completion of edge detection process
         rx_in : in STD_LOGIC;                                                           --rx_in port for serial comms
         tx_out : out STD_LOGIC);                                                         --tx_out port for serial comms
           
end main;

architecture Behavioral of main is

component padded_image is 
  Port (clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
end component;

component input_image is 
  port (clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
end component;

component output_image is 
  port (clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
end component;

component padding is generic (
     pixel_depth_g: integer := 8;                                                         --bit depth of an individual pixel
     input_width_g : integer := 25;                                                        --width of input image in pixels
     address_width_g : integer := 10);                                                    --width of memory address (can address upto 2^10 individual pixels)
      
    Port ( input_img_in : in STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                    
           output_img_out : out STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                  
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           enable_in : in STD_LOGIC;                                      
           enable_out : out STD_LOGIC;                                    
           input_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);           
           output_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);          
           input_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);         
           output_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0)); 
end component; 

component convolve is generic (
     pixel_depth_g: integer := 8;                                                         --bit depth of an individual pixel
     input_width_g : integer := 25;                                                        --width of input image in pixels
     address_width_g : integer := 10);                                                    --width of memory address (can address upto 2^10 individual pixels)
                                        
    Port ( input_img_in : in STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                    
           output_img_out : out STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                  
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           enable_in : in STD_LOGIC;                                      
           enable_out : out STD_LOGIC;                                    
           input_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);           
           output_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);          
           input_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);         
           output_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0));       
end component;

component uart is generic (
     pixel_depth_g: integer := 8;                                                         --bit depth of an individual pixel
     input_width_g : integer := 25;                                                       --width of input image in pixels
     baud_rate : integer := 115200;                                                     --baud rate for comms 
     address_width_g : integer := 10);                                                    --width of memory address (can address upto 2^10 individual pixels)

    Port ( input_img_in : in STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                  
           output_img_out : out STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                 
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           read_en_in : in STD_LOGIC;                                                   
           write_en_in : in STD_LOGIC;                                                   
           read_done_out : out STD_LOGIC;                                                
           write_done_out : out STD_LOGIC;                                                  
           rx_in : in STD_LOGIC;                                                           
           tx_out : out STD_LOGIC;                                                         
           input_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                         
           output_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                        
           input_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);         
           output_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0));       
end component;          

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

signal input_img_padding : STD_LOGIC_VECTOR (7 downto 0);                    
signal output_img_padding : STD_LOGIC_VECTOR (7 downto 0);                  
signal enable_in_padding : STD_LOGIC;                                      
signal enable_out_padding : STD_LOGIC;                                    
signal input_img_enable_out_padding : STD_LOGIC_VECTOR(0 DOWNTO 0);           
signal output_img_enable_out_padding : STD_LOGIC_VECTOR(0 DOWNTO 0);          
signal input_img_address_out_padding : STD_LOGIC_VECTOR (9 downto 0);         
signal output_img_address_out_padding : STD_LOGIC_VECTOR (9 downto 0);  
signal input_img_convolve : STD_LOGIC_VECTOR (7 downto 0);                    
signal output_img_convolve : STD_LOGIC_VECTOR (7 downto 0);                  
signal enable_in_convolve : STD_LOGIC;                                      
signal enable_out_convolve : STD_LOGIC;                                    
signal input_img_enable_out_convolve : STD_LOGIC_VECTOR(0 DOWNTO 0);           
signal output_img_enable_out_convolve : STD_LOGIC_VECTOR(0 DOWNTO 0);          
signal input_img_address_out_convolve : STD_LOGIC_VECTOR (9 downto 0);         
signal output_img_address_out_convolve : STD_LOGIC_VECTOR (9 downto 0);  
signal input_img_uart : STD_LOGIC_VECTOR (7 downto 0);                 
signal output_img_uart : STD_LOGIC_VECTOR (7 downto 0);                  
signal read_en : STD_LOGIC;                                                      
signal write_en : STD_LOGIC;                                                   
signal read_done : STD_LOGIC;                                                   
signal write_done : STD_LOGIC;                                                  
signal input_img_enable_out_uart : STD_LOGIC_VECTOR(0 DOWNTO 0);                        
signal output_img_enable_out_uart : STD_LOGIC_VECTOR(0 DOWNTO 0);                        
signal input_img_address_out_uart : STD_LOGIC_VECTOR (9 downto 0);         
signal output_img_address_out_uart : STD_LOGIC_VECTOR (9 downto 0);
begin

    pad1 : padding
        port map ( input_img_in => input_img_padding,                    
               output_img_out => output_img_padding,                 
               clk => clk,
               rst_n => rst_n,
               enable_in => enable_in_padding,                                      
               enable_out => enable_out_padding,                                  
               input_img_enable_out => input_img_enable_out_padding,           
               output_img_enable_out => output_img_enable_out_padding,     
               input_img_address_out => input_img_address_out_padding,    
               output_img_address_out => output_img_address_out_padding); 
               
    conv1 : convolve
        port map ( input_img_in => input_img_convolve,                    
               output_img_out => output_img_convolve,                 
               clk => clk,
               rst_n => rst_n,
               enable_in => enable_in_convolve,                                      
               enable_out => enable_out_convolve,                                  
               input_img_enable_out => input_img_enable_out_convolve,           
               output_img_enable_out => output_img_enable_out_convolve,     
               input_img_address_out => input_img_address_out_convolve,    
               output_img_address_out => output_img_address_out_convolve); 
        
    input_ram : input_image
        port map ( clka => clk,                    
                   wea => input_img_enable_out_uart,                 
                   addra => input_img_address_out_uart,
                   dina => input_img_uart,                                    
                   clkb => clk,                                  
                   web => input_img_enable_out_padding,           
                   addrb => input_img_address_out_padding,     
                   dinb => "00000000",
                   doutb => input_img_padding); 

    padded_ram : padded_image
        port map ( clka => clk,                    
                   wea => output_img_enable_out_padding,                 
                   addra => output_img_address_out_padding,
                   dina => output_img_padding,                                      
                   clkb => clk,                                  
                   web => input_img_enable_out_convolve,           
                   addrb => input_img_address_out_convolve,     
                   dinb => "00000000",    
                   doutb => input_img_convolve); 

    output_ram : output_image
        port map ( clka => clk,                    
                   wea => output_img_enable_out_convolve,                 
                   addra => output_img_address_out_convolve,
                   dina => output_img_convolve,                                      
                   clkb => clk,                                  
                   web => output_img_enable_out_uart,           
                   addrb => output_img_address_out_uart,     
                   dinb => "00000000",    
                   doutb => output_img_uart); 

    fsm1 : fsm
        port map ( clk => clk,
                   rst_n => rst_n,
                   enable_edge_detection_in => enable_edge_detection_in,
                   edge_detection_done_out => edge_detection_done_out,
                   enable_convolve_out => enable_in_convolve,
                   enable_padding_out => enable_in_padding,
                   convolve_done_in => enable_out_convolve,
                   padding_done_in => enable_out_padding,
                   read_enable_uart_out => read_en,
                   write_enable_uart_out => write_en,
                   uart_read_done_in => read_done,
                   uart_write_done_in => write_done);
                   
    uart1 : uart
        port map ( input_img_in => output_img_uart,
                   output_img_out => input_img_uart,
                   clk => clk,
                   rst_n => rst_n,
                   rx_in => rx_in,
                   tx_out => tx_out,
                   read_en_in => read_en,
                   write_en_in => write_en,
                   read_done_out => read_done,
                   write_done_out => write_done,
                   input_img_enable_out =>  output_img_enable_out_uart,
                   output_img_enable_out => input_img_enable_out_uart,
                   input_img_address_out =>  output_img_address_out_uart,
                   output_img_address_out => input_img_address_out_uart);
end Behavioral;
