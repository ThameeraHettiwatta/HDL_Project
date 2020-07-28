----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/26/2020 11:24:29 AM
-- Design Name: 
-- Module Name: UART - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- NOTE: a buffer is used to read data
entity UART is generic (
     pixel_depth: integer := 8;                                                         --bit depth of an individual pixel
     input_width : integer := 25;                                                       --width of input image in pixels
     baud_rate : integer := 115200;                                                     --baud rate for comms 
     address_width : integer := 10);                                                    --width of memory address (can address upto 2^10 individual pixels)

    Port ( input_img : in STD_LOGIC_VECTOR (pixel_depth-1 downto 0);                    -- data bus for incoming image (input ram)
           output_img : out STD_LOGIC_VECTOR (pixel_depth-1 downto 0);                  -- data bus for output image after convolution (output ram)
           clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           read_en : in STD_LOGIC;                                                      --enable reading from uart
           write_en : in STD_LOGIC;                                                     --enable writing to uart
           read_done : out STD_LOGIC;                                                   --indicate reading completion
           write_done : out STD_LOGIC;                                                  --indicate writing completion
           rx : in STD_LOGIC;                                                           --rx port for serial comms
           tx : out STD_LOGIC;                                                          --tx port for serial comms
           input_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);                         --enable writing values to input ram
           output_img_enable : out STD_LOGIC_VECTOR(0 DOWNTO 0);                        --enable writing values to output ram
           input_img_address : out STD_LOGIC_VECTOR (address_width-1 downto 0);         --address for reading values from input ram
           output_img_address : out STD_LOGIC_VECTOR (address_width-1 downto 0));       --address for writing values to output ram
          
end UART;

architecture Behavioral of UART is

component uart_rx is 
    generic(
        data_bits: integer := pixel_depth;      --  d a t a   b i t s  
        stop_bit_ticks: integer := 16   --  t i c k s   f o r   s t o p   b i t s  
    );
    Port ( rx : in STD_LOGIC;
           clk : in STD_LOGIC;
           reset: in STD_LOGIC;
           tick : in STD_LOGIC;
           rx_done : out STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0));
end component;

component uart_tx is
    generic(
    DBIT : integer := pixel_depth ; --  data bits
        SB_TICK : integer := 16 --  ticks for stop bits
       );
    port (
        clk: in std_logic;
        reset: in std_logic;
        tx_start : in std_logic;
        s_tick: in std_logic ;
        din: in std_logic_vector (7 downto 0) ;
        tx_done_tick: out std_logic;
        tx: out std_logic);
end component;

component baud_generator 
    Port ( Clock : in STD_LOGIC;
           enable : out STD_LOGIC;
           reset : in STD_LOGIC);
end component;

--signals
signal reset_rec: STD_LOGIC;
signal reset_trans: STD_LOGIC;
signal tick : STD_LOGIC;
signal rx_done : STD_LOGIC;
signal tx_start : STD_LOGIC;
signal tx_done : STD_LOGIC;
signal receiver_data_out : STD_LOGIC_VECTOR (7 downto 0);                                                           --handle data coming out of the reciever
signal transmitter_data_in : STD_LOGIC_VECTOR (7 downto 0);                                                         --handle data going in to the transmitter

begin

    receiver : uart_rx
    port map (rx => rx,
               clk => clock,
               reset => reset_rec,
               tick => tick,
               rx_done => rx_done,
               data_out => receiver_data_out);

    transmitter : uart_tx
    port map (clk => clock,
        reset => reset_trans,
        tx_start => tx_start,
        s_tick => tick,
        din => transmitter_data_in,
        tx_done_tick => tx_done,
        tx => tx_done);

    baud_gen : baud_generator
    port map(  Clock => Clock,
               enable => tick,
               reset => reset);
               
    process (clock, input_img, reset, read_en, write_en)
    
    constant input_img_size : integer := input_width * input_width;                     --size of input image in pixels
    constant delay : integer := 3;                                                      --delay before transmitting data (3 clock cycles)
    variable input_pixel_counter : integer := 0;                                        --keep track of number of pixels sent to ram
    variable output_pixel_counter : integer := 0;                                       --keep track of number of pixels read from ram
    variable read_complete : STD_LOGIC := '0';                                          --indicate that all pixels have been read
    variable write_complete : STD_LOGIC := '0';                                          --indicate that all pixels have been written
    variable img_pixel : integer := 0;                                                  --used for storing image pixel value read from ram
    variable current_delay : integer := 0;                                              --used to maintain the tranmission delay
    
    begin
    
        --reset to initial state
        if (reset = '1') then

            write_done <= '0';
            read_done <= '0';
            read_complete := '0';                                                                                           
            write_complete := '0';                                                                                           
            input_pixel_counter := 0;                                                                                      
            output_pixel_counter := 0;                                                                                      
            input_img_enable <= "0";
            output_img_enable <= "0";
            input_img_address <= "0000000000";
            output_img_address <= "0000000000";
            reset_rec <= '1';
            reset_trans <= '1';
            tx_done <= '1';
            tx_start <= '0';
            
        elsif rising_edge(clock) then
        
            --save incoming image   
            if (read_en = '1') then
                reset_rec <= '0';
                if (read_complete = '0') then                                                                               --reading is not complete
                    if (rx_done = '1') then                                                                                 --a pixel is ready
                        output_img_address <= std_logic_vector(to_unsigned(output_pixel_counter, address_width));
                        output_img <= receiver_data_out;
                        output_img_enable <= "1";
                        output_pixel_counter := output_pixel_counter + 1;                                                   --increment pixel counter
                        
                        if (output_pixel_counter >= input_img_size) then                                                    --check if entire image has been read
                            read_complete := '1';
                            read_done <= '1';
                        end if;
                    else
                        output_img_enable <= "0";
                    end if;
                    
                end if;
            end if;
            
            --send output image TODO
            if (write_en = '1') then
                reset_trans <= '1';
                if (write_complete = '0') then                                                                                   --writing is not complete
                    if (input_pixel_counter <= input_img_size) then
                        if (tx_done = '1') or (input_pixel_counter = 0) then                                                     --we can only read a new pixel if the previous pixel is done / process hasn't begun
                            --read a pixel from RAM
                            input_img_address <= std_logic_vector(to_unsigned(input_pixel_counter, address_width));
                            transmitter_data_in <= input_img;                                                                    --shouldn't be used for 3 more clock cycles
                            if (current_delay >= delay) then                                                                     --delay for 3 clock cycles
                                tx_start <= '1';
                                input_pixel_counter := input_pixel_counter +1;                                                   --increment counter
                            else
                                current_delay := current_delay + 1;
                            end if;
                        else
                            tx_start <= '0';
                        end if;
                    else
                        write_complete := '1';
                    end if;
                 end if;
              end if;        

        end if;
        
    end process;
    end Behavioral;
