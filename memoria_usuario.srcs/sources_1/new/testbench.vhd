----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.10.2018 11:51:12
-- Design Name: 
-- Module Name: testbench - Behavioral
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

entity testbench is
end testbench;

architecture Behavioral of testbench is

    component main is
    Port
    (
        clk     : in STD_LOGIC;
        rst     : in STD_LOGIC;
        
        uart_en_o : out STD_LOGIC;              
        uart_rx_i  : in  STD_LOGIC;
        uart_tx_o  : out STD_LOGIC;
        
        rom_ce       : out STD_LOGIC;
        rom_oe       : out STD_LOGIC;
        rom_we       : out STD_LOGIC;         
        rom_wp       : out STD_LOGIC;
        rom_ryby     : in  STD_LOGIC;            
        rom_addr     : out  STD_LOGIC_VECTOR(23 downto 0);
        rom_q        : inout STD_LOGIC_VECTOR(15 downto 0)
    );
    end component;
    
    component uart is
    Port 
      (  
        clk_sys            : in  std_logic;
        rst                : in  std_logic;
        uart_baud_i        : in  std_logic_vector(3 downto 0);
        uart_parity_i      : in  std_logic;
        uart_odd_even_i    : in  std_logic;              
        uart_ld_i          : in  std_logic;
        uart_tx_busy_o     : out std_logic;
        uart_din_i         : in  std_logic_vector(7 downto 0);
        uart_tx_o          : out std_logic;
        uart_rx_rdy_o      : out std_logic;
        uart_rx_i          : in  std_logic;
        uart_dout_o        : out std_logic_vector(7 downto 0);              
        uart_err_o         : out std_logic;
        uart_en_o          : out std_logic
      );      
    end component; 

	signal clk  : std_logic := '0';
	signal rst  : std_logic := '1';
	    
	signal load : std_logic := '0';    
	signal busy : std_logic := '0';
	signal din  : std_logic_vector(7 downto 0) := (others => '0');
	signal tx   : std_logic := '0';
	signal rdy  : std_logic := '0';
	signal rx   : std_logic := '0';
	signal dout : std_logic_vector(7 downto 0) := (others => '0');
	signal err  : std_logic := '0';
	signal en   : std_logic := '0';
	
	signal m_en : std_logic := '0';
	signal ce   : STD_LOGIC := '0';
	signal oe   : STD_LOGIC := '0';
    signal we   : STD_LOGIC := '0';         
    signal wp   : STD_LOGIC := '0';
    signal ryby : STD_LOGIC := '0';            
    signal addr : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    signal q    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
       	    
begin

    clk <= not clk after 5 ns;

	UART_PC: uart
	port map(
		clk_sys            => clk,
		rst                => rst,
		uart_baud_i        => "0011",
		uart_parity_i      => '0',
		uart_odd_even_i    => '0',   
		uart_ld_i          => load,
		uart_tx_busy_o     => busy,
		uart_din_i         => din,
		uart_tx_o          => tx,       
		uart_rx_rdy_o      => rdy,
		uart_rx_i          => rx,
		uart_dout_o        => dout,
		uart_err_o         => err,       
		uart_en_o          => en 
	);
	
	Inst_main : main
	port map(
        clk     => clk,
        rst     => rst,
        
        uart_en_o  => m_en,              
        uart_rx_i  => tx,
        uart_tx_o  => rx,
        
        rom_ce     => ce,   
        rom_oe     => oe, 
        rom_we     => we,          
        rom_wp     => wp, 
        rom_ryby   => ryby,             
        rom_addr   => addr, 
        rom_q      => q 
	);
	
    process
    begin    
        loop        
            wait for 500 us;
            
            din <= X"3E";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"31";
            load <= '1';
            wait for 20 ns;
            load <= '0';
            
            wait for 500 us;
            
            din <= X"35";
            load <= '1';
            wait for 20 ns;
            load <= '0';

            wait for 500 us;
            
            din <= X"34";
            load <= '1';
            wait for 20 ns;
            load <= '0';
            
            wait for 500 us;
            
            din <= X"36";
            load <= '1';
            wait for 20 ns;
            load <= '0';                  
            
            wait for 500 us;
            
            din <= X"43";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"45";
            load <= '1';
            wait for 20 ns;
            load <= '0';                      

            wait for 500 us;
            
            din <= X"33";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"0A";
            load <= '1';
            wait for 20 ns;
            load <= '0';
            
            wait for 2 ms;

            din <= X"3E";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"32";
            load <= '1';
            wait for 20 ns;
            load <= '0';
            
            wait for 500 us;
            
            din <= X"31";
            load <= '1';
            wait for 20 ns;
            load <= '0';

            wait for 500 us;
            
            din <= X"34";
            load <= '1';
            wait for 20 ns;
            load <= '0';
            
            wait for 500 us;
            
            din <= X"36";
            load <= '1';
            wait for 20 ns;
            load <= '0';                  
            
            wait for 500 us;
            
            din <= X"43";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"45";
            load <= '1';
            wait for 20 ns;
            load <= '0';                      

            wait for 500 us;
            
            din <= X"33";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
    
            din <= X"31";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"32";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"33";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"34";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"0A";
            load <= '1';
            wait for 20 ns;
            load <= '0';
            
            wait for 2 ms;
            
            din <= X"3E";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"30";
            load <= '1';
            wait for 20 ns;
            load <= '0';           
            
            wait for 500 us;
            
            din <= X"0A";
            load <= '1';
            wait for 20 ns;
            load <= '0';
            
            wait for 2 ms;
  
            din <= X"3E";
            load <= '1';
            wait for 20 ns;
            load <= '0'; 
            
            wait for 500 us;
            
            din <= X"33";
            load <= '1';
            wait for 20 ns;
            load <= '0';  
                      
            wait for 500 us;
            
            din <= X"0A";
            load <= '1';
            wait for 20 ns;
            load <= '0';
 
            wait for 2 ms;
                                                                                    
        end loop;   
             
    end process;
    
end Behavioral;
