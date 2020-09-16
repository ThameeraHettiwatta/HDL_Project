----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/24/2020 11:27:55 AM
-- Design Name: 
-- Module Name: tb_ram_to_text - Behavioral
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
use std.textio.all;
use IEEE.std_logic_textio.all;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_ram_to_text is
--  Port ( );
end tb_ram_to_text;

architecture Behavioral of tb_ram_to_text is

component ram_to_text is
    Port (data_in : in STD_LOGIC_VECTOR(7 DOWNTO 0);
          write_enable : in STD_LOGIC_VECTOR (0 downto 0) :="0";
          data_out : out STD_LOGIC_VECTOR(7 DOWNTO 0) );
end component;

component padding is 

    Port ( input_img_in : in STD_LOGIC_VECTOR (7 downto 0);                    
           output_img_out : out STD_LOGIC_VECTOR (7 downto 0);                  
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           enable_in : in STD_LOGIC;                                      
           enable_out : out STD_LOGIC;                                    
           input_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);           
           output_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);          
           input_img_address_out : out STD_LOGIC_VECTOR (9 downto 0);         
           output_img_address_out : out STD_LOGIC_VECTOR (9 downto 0)); 
end component;  

component input_image is

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

--component convolve is                                        

--    Port ( input_img_in : in STD_LOGIC_VECTOR (7 downto 0);                    
--           output_img_out : out STD_LOGIC_VECTOR (7 downto 0);                  
--           clk : in STD_LOGIC;
--           rst_n : in STD_LOGIC;
--           enable_in : in STD_LOGIC;                                      
--           enable_out : out STD_LOGIC;                                    
--           input_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);           
--           output_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);          
--           input_img_address_out : out STD_LOGIC_VECTOR (9 downto 0);         
--           output_img_address_out : out STD_LOGIC_VECTOR (9 downto 0));       
           
--end component;

--component padded_image is

--  port (clka : IN STD_LOGIC;
--        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
--        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
--        clkb : IN STD_LOGIC;
--        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
--        dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
--end component;


--define signals
signal input_img : STD_LOGIC_VECTOR (7 downto 0);                    
signal output_img : STD_LOGIC_VECTOR (7 downto 0);                  
signal clk : STD_LOGIC := '1';
signal rst_n : STD_LOGIC;
signal enable_in : STD_LOGIC;                                      
signal enable_out : STD_LOGIC;                                    
signal input_img_enable : STD_LOGIC_VECTOR(0 DOWNTO 0);           
signal output_img_enable : STD_LOGIC_VECTOR(0 DOWNTO 0);          
signal input_img_address : STD_LOGIC_VECTOR (9 downto 0);         
signal output_img_address : STD_LOGIC_VECTOR (9 downto 0);  
signal doutb : STD_LOGIC_VECTOR(7 DOWNTO 0);
--signal pad_douta : STD_LOGIC_VECTOR(7 DOWNTO 0);
--signal pad_doutb : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);

begin

    pad1 : padding
        port map ( input_img_in => input_img,                    
               output_img_out => output_img,                 
               clk => clk,
               rst_n => rst_n,
               enable_in => enable_in,                                      
               enable_out => enable_out,                                  
               input_img_enable_out => input_img_enable,           
               output_img_enable_out => output_img_enable,     
               input_img_address_out => input_img_address,    
               output_img_address_out => output_img_address); 
    
    input_ram : input_image
        port map ( clka => clk,                    
               wea => "0",                 
               addra => input_img_address,
               dina => "00000000",
               douta => input_img,                                      
               clkb => clk,                                  
               web => "0",           
               addrb => "0000000000",     
               dinb => "00000000",    
               doutb => doutb); 

--    conv1 : convolve
--        port map ( input_img_in => input_img,                    
--               output_img_out => output_img,                 
--               clk => clk,
--               rst_n => rst_n,
--               enable_in => enable_in,                                      
--               enable_out => enable_out,                                  
--               input_img_enable_out => input_img_enable,           
--               output_img_enable_out => output_img_enable,     
--               input_img_address_out => input_img_address,    
--               output_img_address_out => output_img_address); 
    
--    input_ram : padded_image
--        port map ( clka => clk,                    
--               wea => "0",                 
--               addra => input_img_address,
--               dina => "00000000",
--               douta => input_img,                                      
--               clkb => clk,                                  
--               web => "0",           
--               addrb => "0000000000",     
--               dinb => "00000000",    
--               doutb => doutb); 
               
    ram_text : ram_to_text
        port map ( data_in => output_img,
          write_enable => output_img_enable,
          data_out => data_out);
          
    clk <= not clk after 5ns;

    stimuli : process 
        begin
            rst_n <= '0';
            enable_in <= '0';
            wait for 20ns;
            
            rst_n <= '1';
            enable_in <= '1';
            wait;
            
        end process;
  
    convert_to_text : process (clk)
        variable out_value : line;
        file padded_ram : text is out "padded_ram.txt";
        begin
            if ( clk 'event and clk = '1' ) then
                if ( output_img_enable = "1" ) then
                    --write(out_value, to_integer(unsigned(output_img_address)), left, 3);
                    --write(out_value, string'(","));
                    write(out_value, to_integer(unsigned(data_out)), left, 3);
                    writeline(padded_ram, out_value);
                end if;
                if ( enable_out = '1' ) then
                    file_close(padded_ram);
                end if;
            end if;
        end process;  

--    convert_to_text : process (clk)
--        variable out_value : line;
--        file convoluted_ram : text is out "convoluted_ram.txt";
--        begin
--            if ( clk 'event and clk = '1' ) then
--                if ( output_img_enable = "1" ) then
--                    write(out_value, to_integer(unsigned(output_img_address)), left, 3);
--                    write(out_value, string'(","));
--                    write(out_value, to_integer(unsigned(data_out)), left, 3);
--                    writeline(convoluted_ram, out_value);
--                end if;
--                if ( enable_out = '1' ) then
--                    file_close(convoluted_ram);
--                end if;
--            end if;
--        end process;

end Behavioral;
