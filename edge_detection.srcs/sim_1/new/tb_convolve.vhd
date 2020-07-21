----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.07.2020 11:31:18
-- Design Name: 
-- Module Name: tb_convolve - Behavioral
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

entity tb_convolve is
--  Port ( );
end tb_convolve;

architecture Behavioral of tb_convolve is

component convolve is                                        

    Port ( input_img : in STD_LOGIC_VECTOR (7 downto 0);                    
           output_img : out STD_LOGIC_VECTOR (7 downto 0);                  
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_in : in STD_LOGIC;                                      
           enable_out : out STD_LOGIC;                                    
           input_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);           
           output_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);          
           input_img_address : out STD_LOGIC_VECTOR (9 downto 0);         
           output_img_address : out STD_LOGIC_VECTOR (9 downto 0));       
           
end component;

component padded_image is

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

--define signals
signal input_img : STD_LOGIC_VECTOR (7 downto 0);                    
signal output_img : STD_LOGIC_VECTOR (7 downto 0);                  
signal clock : STD_LOGIC := '1';
signal reset : STD_LOGIC;
signal enable_in : STD_LOGIC;                                      
signal enable_out : STD_LOGIC;                                    
signal input_img_enable : STD_LOGIC_VECTOR(0 DOWNTO 0);           
signal output_img_enable : STD_LOGIC_VECTOR(0 DOWNTO 0);          
signal input_img_address : STD_LOGIC_VECTOR (9 downto 0);         
signal output_img_address : STD_LOGIC_VECTOR (9 downto 0);  
signal doutb : STD_LOGIC_VECTOR(7 DOWNTO 0);

begin

    conv1 : convolve
        port map ( input_img => input_img,                    
               output_img => output_img,                 
               clock => clock,
               reset => reset,
               enable_in => enable_in,                                      
               enable_out => enable_out,                                  
               input_img_enable => input_img_enable,           
               output_img_enable => output_img_enable,     
               input_img_address => input_img_address,    
               output_img_address => output_img_address); 
    
    input_ram : padded_image
        port map ( clka => clock,                    
               wea => "0",                 
               addra => input_img_address,
               dina => "00000000",
               douta => input_img,                                      
               clkb => clock,                                  
               web => "0",           
               addrb => "0000000000",     
               dinb => "00000000",    
               doutb => doutb); 
        
    clock <= not clock after 5ns;

    stimuli : process 
        begin
            reset <= '1';
            enable_in <= '0';
            wait for 20ns;
            
            reset <= '0';
            enable_in <= '1';
            wait;
            
        end process;
       
--   dump_to_text : process (clock)
--    variable out_value : line;
--    file convolved_ram : text is out "convolved_ram.txt";
--    begin
--        reset <= '1';
--          enable_in <= '0';
--          wait for 10ns;
--        if ( clock 'event and clock = '1' ) then
--            if ( output_img_enable = "1" ) then
--                write(out_value, to_integer(unsigned(output_img_address)), left, 3);
--                write(out_value, string'(","));
--                write(out_value, to_integer(unsigned(output_img)), left, 3);
--                writeline(convolved_ram, out_value);
--            end if;
--            if ( convdone = '1' ) then
--                file_close(convolved_ram);
--            end if;
--        end if;
--    end process;
    
end Behavioral;
