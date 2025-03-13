-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Zhdanovich Iaroslav (xzhdan00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is

signal CNT1 : std_logic_vector(3 downto 0) := "0000";
signal CNT2 : std_logic_vector(6 downto 0) := "0000000";
signal CARRY1 : std_logic := '0';
signal CARRY2 : std_logic := '0';
signal SHIFT_REG : std_logic_vector(7 downto 0) := "00000000";
signal startbit : std_logic := '0';
signal ready : std_logic := '0';
signal stopbit : std_logic := '0';
signal back : std_logic := '0';
signal start_delay : std_logic := '0';
signal stop_delay : std_logic := '0';
signal data_en : std_logic := '0';
signal idle : std_logic := '0';

begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        STARTBIT => startbit,
        READY => ready,
        STOPBIT => stopbit,
        BACK => back,
        START_DELAY => start_delay, 
        STOP_DELAY => stop_delay,
        DATA_EN => data_en,
        IDLE => idle
    );

    DOUT_VLD <= CARRY2;
    DOUT <= SHIFT_REG;

    --CNT1 (4b čitač s carry vystupem):
    process(CNT1, CARRY1, start_delay, CLK)
        begin
            if (rising_edge(CLK) and (start_delay = '1' or stop_delay = '1') and CNT1 = "1111") 
                then CNT1 <= "0000";
                CARRY1 <= '1';
            elsif (rising_edge(CLK) and (start_delay = '1' or stop_delay = '1')) 
                then CNT1 <= CNT1 + 1;
                CARRY1 <= '0';
            end if;
    end process; 

    --CNT2 (7b čitač s carry vystupem):
    process(CNT2, CLK, CARRY2)
        begin
            if rising_edge(CLK) and data_en = '1' then
                if CNT2 = "1111111" then
                    CARRY2 <= '1';
                    CNT2 <= "0000000";
                else CNT2 <= CNT2 + 1;
                    CARRY2 <= '0';
                end if;
            end if;
    end process; 

    --SHIFT_REG (posuvny registr):
    process(CNT2(3), DIN, SHIFT_REG)
        begin 
            if rising_edge(CNT2(3)) 
                then SHIFT_REG(7) <= DIN;
                SHIFT_REG(6) <= SHIFT_REG(7);
                SHIFT_REG(5) <= SHIFT_REG(6);
                SHIFT_REG(4) <= SHIFT_REG(5);
                SHIFT_REG(3) <= SHIFT_REG(4);
                SHIFT_REG(2) <= SHIFT_REG(3);
                SHIFT_REG(1) <= SHIFT_REG(2);
                SHIFT_REG(0) <= SHIFT_REG(1);
            else
            end if;
    end process;

    --Set IDLE state:
    process(CARRY1, back, stop_delay)
        begin 
            if (CARRY1 = '1' and stop_delay = '1')
                then back <= '1';
            else
                back <= '0';
            end if;
    end process;

    --Set START state:
    process(idle, DIN, startbit)
        begin 
            if (idle = '1' and DIN = '0')
                then startbit <= '1';
            else
                startbit <= '0';
            end if;
    end process;

    --Set DATA state:
    process(CARRY1, ready, start_delay)
        begin 
            if (CARRY1 = '1' and start_delay = '1')
                then ready <= '1';
            else
                ready <= '0';
            end if;
    end process;

    --Set STOP state:
    process(CARRY2, stopbit)
        begin 
        stopbit <= CARRY2;
    end process;

end architecture;
