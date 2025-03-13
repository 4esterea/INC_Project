-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Zhdanovich Iaroslav (xzhdan00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       STARTBIT : in std_logic;
       READY : in std_logic;
       STOPBIT : in std_logic;
       BACK : in std_logic;
       START_DELAY : out std_logic;
       STOP_DELAY : out std_logic;
       DATA_EN : out std_logic;
       IDLE : out std_logic
    );
end entity;


architecture behavioral of UART_RX_FSM is
    
    type STATES is (S_IDLE, S_START, S_DATA, S_STOP);
    signal state : STATES := S_IDLE;

begin
    IDLE <= '1' when state = S_IDLE else '0';
    START_DELAY <= '1' when state = S_START else '0';
    DATA_EN <= '1' when state = S_DATA else '0';
    STOP_DELAY <= '1' when state = S_STOP else '0';
    process(CLK)
    begin
        if rising_edge(CLK) then 
            if STARTBIT = '1' then state <= S_START;
            elsif READY = '1' then state <= S_DATA;
            elsif STOPBIT = '1' then state <= S_STOP;
            elsif BACK = '1' then state <= S_IDLE;
            end if;
        end if;
    end process;

end architecture;
