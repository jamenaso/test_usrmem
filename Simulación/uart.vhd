----------------------------------------------------------------------------------
-- Company: GEO Tecnologies SAS
-- Engineer: Jairo Mena Muñoz
-- 
-- Create Date: 02.10.2018 09:58:48
-- Design Name: USB Prueba Unitaria - Módulo UART
-- Module Name: uart - Behavioral
-- Project Name: Prueba Unitaria USB
-- Target Devices: GEO-HCAL-1.0.0
-- Tool Versions: 1.0.0 
-- Description: Módulo que genera las señales de Tx y Rx para una comunicación Serial,
--              Se permite la configuación de la velocidad de transmición (Baut Rate)               
-- 
-- Dependencies: Departamento de Investigación y Desarrollo - GEO Tecnologies SAS
-- 
-- Revision: 1.0 
-- Revision 0.01 - File Created
-- Additional Comments:
-- copyright, © - Jairo Mena - jamenaso@gmail.com
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart is
    generic (
        clock_system : integer := 100000000
    );
    Port (  
    clk_sys            : in  STD_LOGIC;
    rst                : in  STD_LOGIC;
    uart_baud_i        : in  STD_LOGIC_VECTOR(3 downto 0);
    uart_parity_i      : in  STD_LOGIC;
    uart_odd_even_i    : in  STD_LOGIC;              
    uart_ld_i          : in  STD_LOGIC;
    uart_tx_busy_o     : out STD_LOGIC;
    uart_din_i         : in  STD_LOGIC_VECTOR(7 downto 0);
    uart_tx_o          : out STD_LOGIC;
    uart_rx_rdy_o      : out STD_LOGIC;
    uart_rx_i          : in  STD_LOGIC;
    uart_dout_o        : out STD_LOGIC_VECTOR(7 downto 0);              
    uart_err_o         : out STD_LOGIC;
    uart_en_o          : out STD_LOGIC
    );
end uart;

architecture Behavioral of uart is

    constant MAX_DIV: integer := 333334;--300000;
    constant StartBit : std_logic := '0';	
    constant StopBit : std_logic := '1';
    constant NDBits : integer := 8;
    signal baud_sig : std_logic_vector(3 downto 0) := (others =>'0');
    signal parity : std_logic := '0';
    signal parityOddEven : std_logic := '0';		
    signal div_sig : integer range 0 to MAX_DIV := 0;
    
    type state_type_Tx is (idle, load_tx, shift_tx, stop_tx); 
    signal TxFSM : state_type_Tx := idle;
    
    signal baud_count_Tx : integer range 0 to MAX_DIV := 0;
    signal topTx : std_logic := '0';
    signal txBusy : std_logic := '1';
    signal TxBitCnt : integer range 0 to (1+NDBits+1) := 0;	
    signal Tx_Reg : std_logic_vector(NDBits downto 0) := (others =>'0');	
    signal Tx : std_logic := '1';
    
    type state_type_Rx is (idle, start_rx, shift_rx, stop_rx); 
    signal RxFSM : state_type_Rx := idle;
    
    signal baud_count_Rx : integer range 0 to MAX_DIV := 0;
    signal RxBitCnt : integer range 0 to (1+NDBits) := 0;	
    signal RxRstCnt : integer range 0 to NDBits*100 := 0;	
    signal start : std_logic := '1';
    signal stop : std_logic := '0';
    signal parity_Rx : std_logic := '0';	
    signal Rx_Reg : std_logic_vector(NDBits downto 0) := (others =>'0');
    signal dout : std_logic_vector(7 downto 0) := (others =>'0');
    signal RxEn : std_logic := '0';
    signal Clr_baud : std_logic := '0';
    signal RxRdy : std_logic := '0';
    signal RxErr : std_logic := '0';
    signal inputRx : std_logic := '1';
	
begin

baud_sig <= uart_baud_i;
parity <= uart_parity_i;
parityOddEven <= uart_odd_even_i;

-- --------------------------
-- Baud rate selection
-- --------------------------

	with baud_sig select
    div_sig <= (clock_system / 921600) when "0000",
	           (clock_system / 460800) when "0001",
	           (clock_system / 230400) when "0010",
	           (clock_system / 115200) when "0011",
	           (clock_system / 57600)  when "0100",
	           (clock_system / 38400)  when "0101",
	           (clock_system / 19200)  when "0110",
	           (clock_system / 14400)  when "0111",
	           (clock_system / 9600)   when "1000",
	           (clock_system / 7200)   when "1001",
	           (clock_system / 4800)   when "1010",
	           (clock_system / 2400)   when "1011",
	           (clock_system / 1800)   when "1100",
	           (clock_system / 1200)   when "1101",
	           (clock_system / 600)    when "1110",
	           (clock_system / 300)    when "1111",	           
			   (clock_system / 9600)   when others;
			      
---------------------------------------
-- Tx Clock Generation Clock Generation
---------------------------------------

process (rst, clk_sys)
begin
	if (rst = '0') then
		baud_count_Tx <= 0;
		topTx <= '0';
	elsif (clk_sys'event and clk_sys = '1') then ---clock
		if (baud_count_Tx >= div_sig-1) then
			baud_count_Tx <= 0;
			topTx <= '1';
		else
			baud_count_Tx <= baud_count_Tx + 1;
			topTx <= '0';
		end if;
	end if;
end process;

-- --------------------------
-- Tx State Machine
-- --------------------------

process (rst, clk_sys)
begin
	if (rst = '0') then
		TxFSM <= idle;	
		txBusy <= '1';	
		TxBitCnt <= 0;
		Tx <= '1';
		Tx_Reg <= (others =>'0');	
	elsif (clk_sys'event and clk_sys = '1') then 
		case (TxFSM) is
			when idle =>
				if (uart_ld_i = '1') then
					TxFSM <= load_tx;	
					txBusy <= '0';
					Tx_Reg(7 downto 0) <= uart_din_i(7 downto 0);		
					if (parityOddEven = '0') then
						Tx_Reg(8) <= uart_din_i(7) xor uart_din_i(6) xor uart_din_i(5) xor uart_din_i(4) xor uart_din_i(3) xor uart_din_i(2) xor uart_din_i(1) xor uart_din_i(0);					
					else
						Tx_Reg(8) <= not(uart_din_i(7) xor uart_din_i(6) xor uart_din_i(5) xor uart_din_i(4) xor uart_din_i(3) xor uart_din_i(2) xor uart_din_i(1) xor uart_din_i(0));
					end if;
				end if;
			when load_tx => 
				if (topTx = '1') then
					TxFSM <= shift_tx;
					Tx <= StartBit;	
					txBusy <= '0';
					TxBitCnt <= 0;				
				end if;				
			when shift_tx => 
				if (topTx = '1') then			
					txBusy <= '0';	
					TxBitCnt <= TxBitCnt + 1;
					if (parity = '1') then
						if (TxBitCnt = 1+NDBits) then
							TxFSM <= stop_tx;	
							Tx <= StopBit;
						else
							Tx <= Tx_Reg(TxBitCnt);					
						end if;						
					else
						if (TxBitCnt = NDBits) then
							TxFSM <= stop_tx;	
							Tx <= StopBit;
						else
							Tx <= Tx_Reg(TxBitCnt);					
						end if;	
					end if;						
				end if;
			when stop_tx =>
				if (topTx = '1') then
					TxFSM <= idle;	
					txBusy <= '1';	
					TxBitCnt <= 0;
					Tx <= '1';
				end if;
		end case; 
	end if;
end process;
	
uart_tx_o <= Tx;
uart_tx_busy_o <= txBusy;

-- --------------------------
-- Rx Clock Generation Clock Generation
-- --------------------------
			
process (rst, clk_sys)
begin
	if (rst = '0') then
		baud_count_Rx <= 0;
	elsif (clk_sys'event and clk_sys = '1') then 
		if (RxEn = '1') then
			if (baud_count_Rx >= div_sig-1) then
				baud_count_Rx <= 0;
			else
				baud_count_Rx <= baud_count_Rx + 1;					
			end if;
		else
			baud_count_Rx <= 0;
		end if;
	end if;
end process;

-- --------------------------
-- Rx State Machine
-- --------------------------

process (rst, clk_sys)
begin
	if (rst = '0') then
		RxFSM <= idle;
		RxBitCnt <= 0;	
		RxEn <= '0';
		RxRdy <= '0';
		Rx_Reg <= (others =>'0');
		RxErr <= '0';	
		start <= '1';
		stop <= '0';
		dout <= (others =>'0');
	elsif (clk_sys'event and clk_sys = '1') then 
		case (RxFSM) is
			when idle =>
				RxBitCnt <= 0;				
				RxRdy <= '0';
				Rx_Reg <= (others =>'0');	
				start <= '1';
				stop <= '0';
				if (inputRx = '0') then
					RxFSM <= start_rx;		
					RxEn <= '1';
				else
				   RxFSM <= idle;
					RxEn <= '0';
				end if;
			when start_rx => 	
				if (baud_count_Rx = (div_sig-1)/2) then			
					start <= inputRx;						
				end if;	
				if (baud_count_Rx >= div_sig-1) then
					RxFSM <= shift_rx; 								
				end if;
				RxEn <= '1';
			when shift_rx =>
				if (baud_count_Rx = (div_sig-1)/2) then 			
					Rx_Reg(RxBitCnt) <= inputRx;						
				end if;			
				if (baud_count_Rx >= div_sig-1) then
					RxBitCnt <= RxBitCnt + 1;
					if (parity = '1') then
						if (RxBitCnt = NDBits) then
							RxFSM <= stop_rx;	
						end if;						
					else
						if (RxBitCnt = NDBits-1) then
							RxFSM <= stop_rx;	
						end if;	
					end if;								
				end if;
				RxEn <= '1';
			when stop_rx =>
				if (baud_count_Rx = (div_sig-1)/2) then
					stop <= inputRx;
					dout <= Rx_Reg(7 downto 0);
					RxRdy <= '1';
					if (parity = '1') then
						if (parityOddEven = '0') then
							parity_Rx <= Rx_Reg(7) xor Rx_Reg(6) xor Rx_Reg(5) xor Rx_Reg(4) xor Rx_Reg(3) xor Rx_Reg(2) xor Rx_Reg(1) xor Rx_Reg(0);					
						else
							parity_Rx <= not(Rx_Reg(7) xor Rx_Reg(6) xor Rx_Reg(5) xor Rx_Reg(4) xor Rx_Reg(3) xor Rx_Reg(2) xor Rx_Reg(1) xor Rx_Reg(0));
						end if;
					end if;
				else
					RxRdy <= '0';				
				end if;	
				if (baud_count_Rx >= div_sig-1) then 
					RxFSM <= idle;					
					RxBitCnt <= 0;						
					start <= '1';
					stop <= '0';						
					if (start = '0' and stop = '1') then
						if (parity = '1') then
							if (Rx_Reg(8) = parity_Rx) then	
								RxErr <= '0';								
							else
								RxErr <= '1';
							end if;							
						else
							RxErr <= '0';
						end if;					
					else	
						RxErr <= '1';
					end if;				
				end if;	
				RxEn <= '1';				
		end case; 
	end if;
end process;	
			  	
inputRx <= uart_rx_i;
uart_en_o <= RxEn;				
uart_err_o <= RxErr;
uart_rx_rdy_o <= RxRdy;
uart_dout_o <= dout;

end Behavioral;
