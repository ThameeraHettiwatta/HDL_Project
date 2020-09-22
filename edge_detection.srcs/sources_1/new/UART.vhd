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
     pixel_depth_g: integer := 8;                                                         --bit depth of an individual pixel
     input_width_g : integer := 25;                                                       --width of input image in pixels
     address_width_g : integer := 10);                                                    --width of memory address (can address upto 2^10 individual pixels)

    Port ( input_img_in : in STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                    -- data bus for incoming image (input ram)
           output_img_out : out STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                  -- data bus for output image after convolution (output ram)
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           read_en_in : in STD_LOGIC;                                                     --enable reading from uart
           write_en_in : in STD_LOGIC;                                                     --enable writing to uart
           read_done_out : out STD_LOGIC;                                                   --indicate reading completion
           write_done_out : out STD_LOGIC;                                                  --indicate writing completion
           rx_in : in STD_LOGIC;                                                           --rx port for serial comms
           tx_out : out STD_LOGIC;                                                          --tx port for serial comms
           input_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                         --enable writing values to input ram
           output_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                        --enable writing values to output ram
           input_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);         --address for reading values from input ram
           output_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0));       --address for writing values to output ram
          
end UART;

architecture Behavioral of UART is

component uartComms is
    Generic (address_width_g : integer := address_width_g;
             pixel_depth_g : integer := pixel_depth_g;
             input_width_g : integer := input_width_g);

    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           start_rec_in : in STD_LOGIC;
           start_send_in : in STD_LOGIC;
           finished_rec_out : out STD_LOGIC;
           finished_send_out : out STD_LOGIC;
           uart_interrupt_in : in STD_LOGIC;
           uart_s_axi_awaddr_out : out STD_LOGIC_VECTOR(3 DOWNTO 0);
           uart_s_axi_awvalid_out : out STD_LOGIC;
           uart_s_axi_awready_in : in STD_LOGIC;
           uart_s_axi_wdata_out : out STD_LOGIC_VECTOR(31 DOWNTO 0);
           uart_s_axi_wstrb_out : out STD_LOGIC_VECTOR(3 DOWNTO 0);
           uart_s_axi_wvalid_out : out STD_LOGIC;
           uart_s_axi_wready_in : in STD_LOGIC;
           uart_s_axi_bresp_in : in STD_LOGIC_VECTOR(1 DOWNTO 0);
           uart_s_axi_bvalid_in : in STD_LOGIC;
           uart_s_axi_bready_out : out STD_LOGIC;
           uart_s_axi_araddr_out : out STD_LOGIC_VECTOR(3 DOWNTO 0);
           uart_s_axi_arvalid_out : out STD_LOGIC;
           uart_s_axi_arready_in : in STD_LOGIC;
           uart_s_axi_rdata_in : in STD_LOGIC_VECTOR(31 DOWNTO 0);
           uart_s_axi_rresp_in : in STD_LOGIC_VECTOR(1 DOWNTO 0);
           uart_s_axi_rvalid_in : in STD_LOGIC;
           uart_s_axi_rready_out : out STD_LOGIC;
           output_image_add_out : out STD_LOGIC_VECTOR (address_width_g -1 downto 0);
           input_image_add_out : out STD_LOGIC_VECTOR (address_width_g -1 downto 0);
           output_img_out : out STD_LOGIC_VECTOR (pixel_depth_g -1 downto 0);
           input_img_in : in STD_LOGIC_VECTOR (pixel_depth_g -1 downto 0);
           input_img_we_out : out STD_LOGIC_VECTOR (0 downto 0);
           output_img_we_out : out STD_LOGIC_VECTOR (0 downto 0));

end component;

component axi_uartlite_0 is
    Port (s_axi_aclk : IN STD_LOGIC;
          s_axi_aresetn : IN STD_LOGIC;
          interrupt : OUT STD_LOGIC;
          s_axi_awaddr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          s_axi_awvalid : IN STD_LOGIC;
          s_axi_awready : OUT STD_LOGIC;
          s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          s_axi_wvalid : IN STD_LOGIC;
          s_axi_wready : OUT STD_LOGIC;
          s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          s_axi_bvalid : OUT STD_LOGIC;
          s_axi_bready : IN STD_LOGIC;
          s_axi_araddr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          s_axi_arvalid : IN STD_LOGIC;
          s_axi_arready : OUT STD_LOGIC;
          s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          s_axi_rvalid : OUT STD_LOGIC;
          s_axi_rready : IN STD_LOGIC;
          rx : IN STD_LOGIC;
          tx : OUT STD_LOGIC);
end component;

--signals
signal rst_n_rec: STD_LOGIC;
signal rst_n_trans: STD_LOGIC;
signal tick : STD_LOGIC;
signal rx_done : STD_LOGIC;
signal tx_start : STD_LOGIC;
signal tx_done : STD_LOGIC;
signal receiver_data_out : STD_LOGIC_VECTOR (7 downto 0);                                                           --handle data coming out of the reciever
signal transmitter_data_in : STD_LOGIC_VECTOR (7 downto 0);                                                         --handle data going in to the transmitter

signal s_axi_awaddr_comm_to_auu : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal s_axi_awvalid_comm_to_auu : STD_LOGIC;
signal s_axi_awready_auu_to_comm : STD_LOGIC;
signal s_axi_wdata_comm_to_auu : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal s_axi_wstrb_comm_to_auu : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal s_axi_wvalid_comm_to_auu : STD_LOGIC;
signal s_axi_wready_auu_to_comm : STD_LOGIC;
signal s_axi_bresp_auu_to_comm : STD_LOGIC_VECTOR(1 DOWNTO 0);
signal s_axi_bvalid_auu_to_comm : STD_LOGIC;
signal s_axi_bready_comm_to_auu : STD_LOGIC;
signal s_axi_araddr_comm_to_auu : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal s_axi_arvalid_comm_to_auu : STD_LOGIC;
signal s_axi_arready_auu_to_comm : STD_LOGIC;
signal s_axi_rdata_auu_to_comm : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal s_axi_rresp_auu_to_comm : STD_LOGIC_VECTOR(1 DOWNTO 0);
signal s_axi_rvalid_auu_to_comm : STD_LOGIC;
signal s_axi_rready_comm_to_auu : STD_LOGIC;
signal interrupt_auu_to_comm : STD_LOGIC;

begin


uart_communication_unit_1_comm : uartComms
    port map (clk => clk,
              rst_n =>rst_n,
              start_rec_in => read_en_in,
              start_send_in => write_en_in,
              finished_send_out => write_done_out,
              finished_rec_out => read_done_out,
              uart_interrupt_in => interrupt_auu_to_comm,
              uart_s_axi_awaddr_out => s_axi_awaddr_comm_to_auu,
              uart_s_axi_awvalid_out => s_axi_awvalid_comm_to_auu,
              uart_s_axi_awready_in => s_axi_awready_auu_to_comm,
              uart_s_axi_wdata_out => s_axi_wdata_comm_to_auu,
              uart_s_axi_wstrb_out => s_axi_wstrb_comm_to_auu,
              uart_s_axi_wvalid_out => s_axi_wvalid_comm_to_auu,
              uart_s_axi_wready_in => s_axi_wready_auu_to_comm,
              uart_s_axi_bresp_in => s_axi_bresp_auu_to_comm,
              uart_s_axi_bvalid_in => s_axi_bvalid_auu_to_comm,
              uart_s_axi_bready_out => s_axi_bready_comm_to_auu,
              uart_s_axi_araddr_out => s_axi_araddr_comm_to_auu,
              uart_s_axi_arvalid_out => s_axi_arvalid_comm_to_auu,
              uart_s_axi_arready_in => s_axi_arready_auu_to_comm,
              uart_s_axi_rdata_in => s_axi_rdata_auu_to_comm,
              uart_s_axi_rresp_in => s_axi_rresp_auu_to_comm,
              uart_s_axi_rvalid_in => s_axi_rvalid_auu_to_comm,
              uart_s_axi_rready_out => s_axi_rready_comm_to_auu,
              output_image_add_out => output_img_address_out,
              input_image_add_out => input_img_address_out,
              input_img_in => input_img_in,
              output_img_out => output_img_out,
              input_img_we_out => input_img_enable_out,
              output_img_we_out => output_img_enable_out);

axi_uartlite_module_1_auu : axi_uartlite_0
    port map (s_axi_aclk => clk,
              s_axi_aresetn => rst_n,
              interrupt => interrupt_auu_to_comm,
              s_axi_awaddr => s_axi_awaddr_comm_to_auu,
              s_axi_awvalid => s_axi_awvalid_comm_to_auu,
              s_axi_awready => s_axi_awready_auu_to_comm,
              s_axi_wdata => s_axi_wdata_comm_to_auu,
              s_axi_wstrb => s_axi_wstrb_comm_to_auu,
              s_axi_wvalid => s_axi_wvalid_comm_to_auu,
              s_axi_wready => s_axi_wready_auu_to_comm,
              s_axi_bresp => s_axi_bresp_auu_to_comm,
              s_axi_bvalid => s_axi_bvalid_auu_to_comm,
              s_axi_bready => s_axi_bready_comm_to_auu,
              s_axi_araddr => s_axi_araddr_comm_to_auu,
              s_axi_arvalid => s_axi_arvalid_comm_to_auu,
              s_axi_arready => s_axi_arready_auu_to_comm,
              s_axi_rdata => s_axi_rdata_auu_to_comm,
              s_axi_rresp => s_axi_rresp_auu_to_comm,
              s_axi_rvalid => s_axi_rvalid_auu_to_comm,
              s_axi_rready => s_axi_rready_comm_to_auu,
              rx => rx_in,
              tx => tx_out);
               
    end Behavioral;
