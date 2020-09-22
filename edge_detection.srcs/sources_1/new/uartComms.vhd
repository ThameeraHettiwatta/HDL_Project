----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/21/2020 09:34:11 PM
-- Design Name: 
-- Module Name: uart_receive - Behavioral
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


entity uartComms is
    Generic (address_width_g : integer := 10;                                                               --width of memory address (can address upto 2^10 individual pixels)
             pixel_depth_g : integer := 8;                                                                  --bit depth of an individual pixel
            input_width_g : integer := 25);                                                                 --width of input image in pixels
            
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           start_rec_in : in STD_LOGIC;                                                                     --begin recieving data
           finished_rec_out : out STD_LOGIC := '0';                                                         --notify end of data receipt
           start_send_in : in STD_LOGIC;                                                                    --begin sending data
           finished_send_out : out STD_LOGIC := '0';                                                        --notify end of data transmission
           uart_interrupt_in : in STD_LOGIC;                                                                --uart interrupt
           uart_s_axi_awaddr_out : out STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";                              --uart output write address
           uart_s_axi_awvalid_out : out STD_LOGIC := '0';                                                   --uart write address valid
           uart_s_axi_awready_in : in STD_LOGIC;                                                            --uart read address ready
           uart_s_axi_wdata_out : out STD_LOGIC_VECTOR(31 DOWNTO 0) := std_logic_vector(to_unsigned(0, 32));--uart output data port
           uart_s_axi_wstrb_out : out STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";                               --uart write strobe selection                               
           uart_s_axi_wvalid_out : out STD_LOGIC := '0';                                                    --uart write data valid
           uart_s_axi_wready_in : in STD_LOGIC;                                                             --uart write data ready
           uart_s_axi_bresp_in : in STD_LOGIC_VECTOR(1 DOWNTO 0);                                           --uart write done input
           uart_s_axi_bvalid_in : in STD_LOGIC;                                                             --uart write ready input
           uart_s_axi_bready_out : out STD_LOGIC := '0';                                                    --uart  write data ready
           uart_s_axi_araddr_out : out STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";                              --uart input read address
           uart_s_axi_arvalid_out : out STD_LOGIC := '0';                                                   --uart input address valid
           uart_s_axi_arready_in : in STD_LOGIC;                                                            --uart read address ready
           uart_s_axi_rdata_in : in STD_LOGIC_VECTOR(31 DOWNTO 0);                                          --uart input data port
           uart_s_axi_rresp_in : in STD_LOGIC_VECTOR(1 DOWNTO 0);                                           --uart read done input
           uart_s_axi_rvalid_in : in STD_LOGIC;                                                             --uart read data valid input
           uart_s_axi_rready_out : out STD_LOGIC := '0';                                                   --uart ready to read
           output_image_add_out : out STD_LOGIC_VECTOR (address_width_g -1 downto 0) := std_logic_vector(to_unsigned(0, address_width_g));  --output img ram address
           input_image_add_out : out STD_LOGIC_VECTOR (address_width_g -1 downto 0) := std_logic_vector(to_unsigned(0, address_width_g));   --input img ram address
           output_img_out : out STD_LOGIC_VECTOR (pixel_depth_g -1 downto 0) := std_logic_vector(to_unsigned(0, pixel_depth_g));            --data port for output img ram
           input_img_in : in STD_LOGIC_VECTOR (pixel_depth_g -1 downto 0);                                                                  --data port for input img ram
           input_img_we_out : out STD_LOGIC_VECTOR (0 downto 0) := "0";                                     --write elable for input img ram
           output_img_we_out : out STD_LOGIC_VECTOR (0 downto 0) := "0");                                    --write enable for output img ram

end uartComms;

architecture Behavioral of uartComms is

type main_state is (Idle, Set_CTRL_Reg, Fetching, Sending, Receiving, Storing, Incrementing_Send, Incrementing_Rec, Done);
signal comm_state : main_state;

-- AXI data transfer states

type axi_state is (Set_Rx_Write_Up, Wait_Rx_Ready, Set_Tx_Write_Down,
                   Set_Write_Resp_Up, Set_Write_Resp_Down, Wait_Tx_Done,
                   Set_CR_Write_Up, Wait_CR_Ready, Set_CR_Write_Down,
                   Set_CR_Normal, Get_Rx_Data, Set_Read_Ready_High,
                   Set_Read_Ready_Low, Interrupt_wait,
                   Set_Tx_Write_Up, Wait_Tx_Ready);
signal axi_rx_sub_state : axi_state; --axi reciever substates
signal axi_tx_sub_state : axi_state; --axi transmitter substates

signal axi_set_cr_sub_state : axi_state;
signal img_pixel : STD_LOGIC_VECTOR (pixel_depth_g -1 downto 0);                -- used to currently pixel data

signal rec_op : STD_LOGIC;                                                      -- used to indicate receiving / sending

begin

    process (clk, rst_n)
        constant img_size : integer := input_width_g * input_width_g;           -- image size (width x width)
        constant write_wait_delay : integer := 3;                               -- read delay of 3 cycles (1 cycle to update address + 2 cycles delay from IP core), therefore memory read is delayed by 3 cycles
        constant fetch_wait_delay : integer := 3;                               -- read delay of 3 cycles (1 cycle to update address + 2 cycles delay from IP core), therefore memory read is delayed by 3 cycles
        variable mem_addra : integer := 0;                                      -- memory address for reading and writing
        variable write_wait : integer := 0;                                     -- delay for writing data
        variable fetch_wait : integer := 0;                                     -- delay for fetching data
        variable clear_rx_tx : STD_LOGIC := '1';                                -- indicate if the ccurrent data can be cleared
       
        begin
            if (rst_n = '0') then
                comm_state <= Idle;
                img_pixel <= std_logic_vector(to_unsigned(0, img_pixel 'length));
                mem_addra := 0;
                write_wait := 0;
                clear_rx_tx := '1';
                finished_rec_out <= '0';
                finished_send_out <= '0';
                rec_op <= '0';
            elsif (clk 'event and clk = '1') then
                case comm_state is
                    --idle state - system is awaiting a signal to begin either sending or receiving data.
                    when Idle =>
                        input_img_we_out <= "0";
                        output_img_we_out <= "0";
                        --finished_rec_out <= '0';
                        --finished_send_out <= '0';
                        img_pixel <= std_logic_vector(to_unsigned(0, img_pixel 'length));
                        if (start_rec_in = '1') then
                            rec_op <= '1';
                        end if;
                        if (start_send_in = '1') then
                            rec_op <= '0';
                        end if;
                        if (start_rec_in = '1' or start_send_in = '1') then
                            comm_state <= Set_CTRL_Reg;
                            axi_set_cr_sub_state <= Set_CR_Write_Up;
                            clear_rx_tx := '1';
                        end if;
                        
                    --prepare for data transmission by completing the required axi sub states.  Move to either fetching or receiving state when ready
                    when Set_CTRL_Reg =>
                        case axi_set_cr_sub_state is
                            when Set_CR_Write_Up =>
                                --set axi write address to uart control reg address.
                                --set to read from last 8bit of the data.
                                uart_s_axi_awaddr_out <= "1100";
                                uart_s_axi_wstrb_out <= "0001";
                                --select between values to the control register.
                                if (clear_rx_tx = '1') then
                                    --set control reg to enable uart interrupt
                                    --and to clear rx and tx fifo.
                                    uart_s_axi_wdata_out <= "00000000000000000000000000010011";
                                else
                                    --set control reg to enable uart interrupt
                                    --and not to clear rx and tx fifo.
                                    uart_s_axi_wdata_out <= "00000000000000000000000000010000";
                                end if;
                                --set write address and write data valid.
                                uart_s_axi_awvalid_out <= '1';
                                uart_s_axi_wvalid_out <= '1';
                                axi_set_cr_sub_state <= Wait_CR_Ready;
                            when Wait_CR_Ready =>
                                --wait till write ready signal.
                                if (uart_s_axi_awready_in = '1' and uart_s_axi_wready_in = '1') then
                                    axi_set_cr_sub_state <= Set_CR_Write_Down;
                                end if;
                            when Set_CR_Write_Down =>
                                --set write address and write data invalid.
                                uart_s_axi_awvalid_out <= '0';
                                uart_s_axi_wvalid_out <= '0';
                                axi_set_cr_sub_state <= Set_Write_Resp_Up;
                            when Set_Write_Resp_Up =>
                                --wait till write response from slave.
                                if (uart_s_axi_bvalid_in = '1') then
                                    --set master write response high.
                                    uart_s_axi_bready_out <= '1';
                                    axi_set_cr_sub_state <= Set_Write_Resp_Down;
                                end if;
                            when Set_Write_Resp_Down =>
                                --set master write response low.
                                uart_s_axi_bready_out <= '0';
                                axi_set_cr_sub_state <= Set_CR_Normal;
                            when Set_CR_Normal =>
                                --switch between values to the control register.
                                if (clear_rx_tx = '1') then
                                    clear_rx_tx := '0';
                                    axi_set_cr_sub_state <= Set_CR_Write_Up;
                                else
                                    --select between next states based on the
                                    --operation to perform.
                                    if (rec_op = '1') then
                                        comm_state <= Receiving;
                                        axi_rx_sub_state <= Interrupt_wait;
                                    else
                                        comm_state <= Fetching;
                                    end if;
                                end if;
                            when others =>
                                null;
                        end case;
                        
                    --Upon receiving interrupt from uart module indicating data is ready, read data from uart module
                    when Receiving =>
                        case axi_rx_sub_state is
                            when Interrupt_wait =>
                                --wait till the interrupt signalling new data
                                --present in the rx fifo.
                                if(uart_interrupt_in = '1') then
                                    axi_rx_sub_state <= Set_Rx_Write_Up;
                                end if;
                            when Set_Rx_Write_Up =>
                                --set read address to uart rx fifo address.
                                --set read address valid.
                                uart_s_axi_araddr_out <= "0000";
                                uart_s_axi_arvalid_out <= '1';
                                axi_rx_sub_state <= Wait_Rx_Ready;
                            when Wait_Rx_Ready =>
                                --wait till read address ready signal.
                                if (uart_s_axi_arready_in = '1') then
                                    axi_rx_sub_state <= Get_Rx_Data;
                                end if;
                            when Get_Rx_Data =>
                                --set read address invalid.
                                uart_s_axi_arvalid_out <= '0';
                                axi_rx_sub_state <= Set_Read_Ready_High;
                            when Set_Read_Ready_High =>
                                --set read ready signal.
                                uart_s_axi_rready_out<='1';
                                if (uart_s_axi_rvalid_in = '1') then
                                    --if read data valid, read it.
                                    img_pixel <= std_logic_vector(resize(unsigned(uart_s_axi_rdata_in), output_img_out 'length));
                                    axi_rx_sub_state <= Set_Read_Ready_Low;
                                end if;
                            when Set_Read_Ready_Low =>
                                --set read ready signal low and move to storing.
                                uart_s_axi_rready_out <= '0';
                                axi_rx_sub_state <= Interrupt_wait;
                                comm_state <= Storing;
                            when others =>
                                null;
                        end case;
                    
                    --store received data in memory
                    when Storing =>
                        if (write_wait = 0) then
                            --write received data to current memory loaction and wait.
                            output_image_add_out <= std_logic_vector(to_unsigned(mem_addra, output_image_add_out 'length));
                            output_img_out <= img_pixel;
                            output_img_we_out <= "1";
                            write_wait := 1;
                        elsif (write_wait = write_wait_delay) then
                            --if write wait is over, move to Increment_Rec to
                            --obtain next write address.
                            output_img_we_out <= "0";
                            write_wait := 0;
                            comm_state <= Incrementing_Rec;
                        else
                            write_wait := write_wait + 1;
                        end if;
                        
                    --fetch data from memory in order to transmit. When data is ready, move to sending state
                    when Fetching =>
                        if (fetch_wait = 0) then
                            --set address to read from current memory loaction.
                            input_img_we_out <= "0";
                            input_image_add_out <= std_logic_vector(to_unsigned(mem_addra, input_image_add_out 'length));
                            fetch_wait := 1;
                        elsif (fetch_wait = fetch_wait_delay) then
                            --if read wait is over, read the data and move to
                            --sending state. 
                            img_pixel <= input_img_in;
                            fetch_wait := 0;
                            comm_state <= Sending;
                            axi_tx_sub_state <= Set_Tx_Write_Up;
                        else
                            fetch_wait := fetch_wait + 1;
                        end if;
                        
                    --send fetched data using the uart module
                    when Sending =>
                        case axi_tx_sub_state is
                            when Set_Tx_Write_Up =>
                                --set write address to uart tx fifo.
                                --set fetched pixel data as write data.
                                uart_s_axi_awaddr_out <= "0100";
                                uart_s_axi_wdata_out <= std_logic_vector(resize(unsigned(img_pixel), uart_s_axi_wdata_out 'length));
                                --set write address and write data valid.
                                uart_s_axi_awvalid_out <= '1';
                                uart_s_axi_wvalid_out <= '1';
                                axi_tx_sub_state <= Wait_Tx_Ready;
                            when Wait_Tx_Ready =>
                                --wait til  slave signals write ready.
                                if (uart_s_axi_awready_in = '1' and uart_s_axi_wready_in = '1') then
                                    axi_tx_sub_state <= Set_Tx_Write_Down;
                                end if;
                            when Set_Tx_Write_Down =>
                                --set write address and data invalid.
                                uart_s_axi_awvalid_out <= '0';
                                uart_s_axi_wvalid_out <= '0';
                                axi_tx_sub_state <= Set_Write_Resp_Up;
                            when Set_Write_Resp_Up =>
                                --wait till slaves write response.
                                if (uart_s_axi_bvalid_in = '1') then
                                    --set master write response high.
                                    uart_s_axi_bready_out <= '1';
                                    axi_tx_sub_state <= Set_Write_Resp_Down;
                                end if;
                            when Set_Write_Resp_Down =>
                                --set master write response low.
                                uart_s_axi_bready_out <= '0';
                                axi_tx_sub_state <= Wait_Tx_Done;
                            when Wait_Tx_Done =>
                                --wait till the interrupt signalling tx fifo
                                --is empty and move to acqure next memory
                                --location to fetch.
                                if (uart_interrupt_in = '1') then
                                    axi_tx_sub_state <= Set_Tx_Write_Up;
                                    comm_state <= Incrementing_Send;
                                end if;
                            when others =>
                                null;
                        end case;
                    
                    --check if entire image has been recieved, if not, increment the memory location for storing input data
                    when Incrementing_Rec =>
                        output_img_we_out <= "0";
                        if (mem_addra = img_size-1) then
                            --if all data is recieved, move to done state.
                            finished_rec_out <= '1';
                            comm_state <= Done;
                        else
                            --get the nect memory loaction to reecive.
                            mem_addra := mem_addra + 1;
                            comm_state <= Receiving;
                        end if;
                        
                    --check if the entire image has been sent, if not, increment memory location for reading output data
                    when Incrementing_Send =>
                        if (mem_addra = img_size-1) then
                            --if all data is sent, move to done state.
                            finished_send_out <= '1';
                            comm_state <= Done;
                        else
                            --get the next memnry location to send.
                            mem_addra := mem_addra + 1;
                            comm_state <= Fetching;
                        end if;
                    
                    --complete transmission of data, and move back into idle state
                    when Done =>
                        mem_addra := 0;
                        write_wait := 0;
                        fetch_wait := 0;
                        img_pixel <= std_logic_vector(to_unsigned(0, img_pixel 'length));
                        comm_state <= Idle;
                    when others =>
                        null;
                end case;
            end if;
        end process;
end Behavioral;

