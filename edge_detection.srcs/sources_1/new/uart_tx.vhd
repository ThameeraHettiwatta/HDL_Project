----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/26/2020 07:21:43 PM
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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

--uart data transmitter module based on text book - FPGA PROTOTYPING BY VHDL EXAMPLES, Pong P. Chu

entity uart_tx is
    generic(
    DBIT_g : integer := 8 ; --  data bits
        SB_TICK_g : integer := 16 --  ticks for stop bits
       );
    port (
        clk: in std_logic;
        rst_n: in std_logic;
        tx_start_in : in std_logic;
        s_tick_in: in std_logic ;
        din: in std_logic_vector (7 downto 0) ;
        tx_done_tick_out: out std_logic;
        tx_out : out std_logic
    );

end uart_tx;

architecture arch of uart_tx is

TYPE state_type IS (idle, start, data, stop);
SIGNAL state_reg, state_next : state_type;
SIGNAL s_reg, s_next : unsigned (3 DOWNTO 0);
SIGNAL n_reg, n_next : unsigned (2 DOWNTO 0);
SIGNAL b_reg, b_next : std_logic_vector (7 DOWNTO 0);
SIGNAL tx_reg, tx_next : std_logic;

BEGIN

registers : PROCESS (clk, rst_n)
BEGIN
    IF rst_n = '0' THEN
        state_reg <= idle;
        s_reg <= (OTHERS => '0');
        n_reg <= (OTHERS => '0');
        b_reg <= (OTHERS => '0');
        tx_reg <= '1';
    elsif rising_edge(clk) THEN
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
        tx_reg <= tx_next;
    END IF;
END PROCESS registers;
-- next_state logic 

state_machine : PROCESS (state_reg, s_reg, n_reg, b_reg, s_tick_in, tx_reg, tx_start_in, din)

BEGIN
    state_next <= state_reg;
    s_next <= s_reg;
    n_next <= n_reg;
    b_next <= b_reg;
    tx_next <= tx_reg;
    tx_done_tick_out <= '0';

    CASE state_reg IS
       
        WHEN idle =>                                            --idle state, no communication takes place
            tx_next <= '1';
            IF tx_start_in = '1' THEN
                state_next <= start;
                s_next <= (OTHERS => '0');
                b_next <= din;
            END IF;
        
        WHEN start =>                                           --indicate the begining of transmission of data
            tx_next <= '0';                                     --by sending 16 consecutive ticks
            IF (s_tick_in = '1') THEN
                IF s_reg = 15 THEN
                    state_next <= data;
                    s_next <= (OTHERS => '0');
                    n_next <= (OTHERS => '0');
                ELSE
                    s_next <= s_reg + 1;
                END IF;
            END IF;
        
        WHEN data =>                                            --write each bit of output byte into
            tx_next <= b_reg (0);                               --tx line
            IF (s_tick_in = '0') THEN
                IF s_reg = 15 THEN
                    s_next <= (OTHERS => '0');
                    b_next <= '0' & b_reg (7 DOWNTO 1);
                    IF n_reg = (DBIT_g - 1) THEN                  --check for the end of data
                        state_next <= stop;
                    ELSE
                        n_next <= n_reg + 1;
                    END IF;
                ELSE
                    s_next <= s_reg + 1;
                END IF;
            END IF;
        
        WHEN stop =>                                            --send ticks to indicate the end of data
            tx_next <= '1';                                     --and transition to idle state
            IF (s_tick_in = '1') THEN
                IF s_reg = (SB_TICK_g - 1) THEN
                    state_next <= idle;
                    tx_done_tick_out <= '1';
                ELSE
                    s_next <= s_reg + 1;
                END IF;
            END IF;
    
    END CASE;
END PROCESS state_machine;
tx_out <= tx_reg;
END arch;