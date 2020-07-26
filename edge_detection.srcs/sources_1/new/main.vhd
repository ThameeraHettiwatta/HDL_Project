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
  Port ( clock : in STD_LOGIC;
         reset : in STD_LOGIC;
         enable_edge_detection : in STD_LOGIC;                                         --enable signal of start edge detection process       
         edge_detection_done : out STD_LOGIC := '0');                                  --signal to indicate the completion of edge detection process

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

component padding is generic (
     pixel_depth: integer := 8;                                                         --bit depth of an individual pixel
     input_width : integer := 7;                                                        --width of input image in pixels
     address_width : integer := 10);                                                    --width of memory address (can address upto 2^10 individual pixels)
      
    Port ( input_img : in STD_LOGIC_VECTOR (pixel_depth-1 downto 0);                    
           output_img : out STD_LOGIC_VECTOR (pixel_depth-1 downto 0);                  
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_in : in STD_LOGIC;                                      
           enable_out : out STD_LOGIC;                                    
           input_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);           
           output_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);          
           input_img_address : out STD_LOGIC_VECTOR (address_width-1 downto 0);         
           output_img_address : out STD_LOGIC_VECTOR (address_width-1 downto 0)); 
end component; 

component convolve is generic (
     pixel_depth: integer := 8;                                                         --bit depth of an individual pixel
     input_width : integer := 7;                                                        --width of input image in pixels
     address_width : integer := 10);                                                    --width of memory address (can address upto 2^10 individual pixels)
                                        
    Port ( input_img : in STD_LOGIC_VECTOR (pixel_depth-1 downto 0);                    
           output_img : out STD_LOGIC_VECTOR (pixel_depth-1 downto 0);                  
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_in : in STD_LOGIC;                                      
           enable_out : out STD_LOGIC;                                    
           input_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);           
           output_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);          
           input_img_address : out STD_LOGIC_VECTOR (address_width-1 downto 0);         
           output_img_address : out STD_LOGIC_VECTOR (address_width-1 downto 0));       
end component;

component fsm is
  Port (   clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_edge_detection : in STD_LOGIC;                                              
           edge_detection_done : out STD_LOGIC;                                          
           enable_convolve : out STD_LOGIC;                                                
           enable_padding : out STD_LOGIC;                                          
           convolve_done : in STD_LOGIC;                                                  
           padding_done : in STD_LOGIC );                                                
end component;

signal input_img_padding : STD_LOGIC_VECTOR (7 downto 0);                    
signal output_img_padding : STD_LOGIC_VECTOR (7 downto 0);                  
signal enable_in_padding : STD_LOGIC;                                      
signal enable_out_padding : STD_LOGIC;                                    
signal input_img_enable_padding : STD_LOGIC_VECTOR(0 DOWNTO 0);           
signal output_img_enable_padding : STD_LOGIC_VECTOR(0 DOWNTO 0);          
signal input_img_address_padding : STD_LOGIC_VECTOR (9 downto 0);         
signal output_img_address_padding : STD_LOGIC_VECTOR (9 downto 0);  
signal input_img_convolve : STD_LOGIC_VECTOR (7 downto 0);                    
signal output_img_convolve : STD_LOGIC_VECTOR (7 downto 0);                  
signal enable_in_convolve : STD_LOGIC;                                      
signal enable_out_convolve : STD_LOGIC;                                    
signal input_img_enable_convolve : STD_LOGIC_VECTOR(0 DOWNTO 0);           
signal output_img_enable_convolve : STD_LOGIC_VECTOR(0 DOWNTO 0);          
signal input_img_address_convolve : STD_LOGIC_VECTOR (9 downto 0);         
signal output_img_address_convolve : STD_LOGIC_VECTOR (9 downto 0);  

begin

    pad1 : padding
        port map ( input_img => input_img_padding,                    
               output_img => output_img_padding,                 
               clock => clock,
               reset => reset,
               enable_in => enable_in_padding,                                      
               enable_out => enable_out_padding,                                  
               input_img_enable => input_img_enable_padding,           
               output_img_enable => output_img_enable_padding,     
               input_img_address => input_img_address_padding,    
               output_img_address => output_img_address_padding); 
               
    conv1 : convolve
        port map ( input_img => input_img_convolve,                    
               output_img => output_img_convolve,                 
               clock => clock,
               reset => reset,
               enable_in => enable_in_convolve,                                      
               enable_out => enable_out_convolve,                                  
               input_img_enable => input_img_enable_convolve,           
               output_img_enable => output_img_enable_convolve,     
               input_img_address => input_img_address_convolve,    
               output_img_address => output_img_address_convolve); 
        
    input_ram : input_image
        port map ( clka => clock,                    
                   wea => "0",                 
                   addra => input_img_address_padding,
                   dina => "00000000",
                   douta => input_img_padding,                                      
                   clkb => clock,                                  
                   web => output_img_enable_convolve,           
                   addrb => output_img_address_convolve,     
                   dinb => output_img_convolve); 

    output_ram : padded_image
        port map ( clka => clock,                    
                   wea => output_img_enable_padding,                 
                   addra => output_img_address_padding,
                   dina => output_img_padding,                                      
                   clkb => clock,                                  
                   web => input_img_enable_convolve,           
                   addrb => input_img_address_convolve,     
                   dinb => "00000000",    
                   doutb => input_img_convolve); 

    fsm1 : fsm
        port map ( clock => clock,
                   reset => reset,
                   enable_edge_detection => enable_edge_detection,
                   edge_detection_done => edge_detection_done,
                   enable_convolve => enable_in_convolve,
                   enable_padding => enable_in_padding,
                   convolve_done => enable_out_convolve,
                   padding_done => enable_out_padding );

end Behavioral;
