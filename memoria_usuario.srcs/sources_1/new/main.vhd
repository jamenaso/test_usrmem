----------------------------------------------------------------------------------
-- Company: GEO Tecnologies SAS
-- Engineer: Jairo Mena Muñoz
-- 
-- Create Date: 25.10.2018 15:52:26
-- Design Name: Memoria de Usuario Prueba unitaria - Módulo Principal
-- Module Name: main - Behavioral
-- Project Name: Prueba Unitaria UsrMem  
-- Target Devices: GEO-HCAL-1.0.0
-- Tool Versions: 1.0.0 
-- Description: 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main is
    Port (    
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
end main;

architecture Behavioral of main is
    
    component usrmem
    Port 
    ( 
        clk         : in STD_LOGIC;
        rst         : in STD_LOGIC; 
        en          : in STD_LOGIC;
        cmd         : in STD_LOGIC_VECTOR (2 downto 0);
        addr_in     : in STD_LOGIC_VECTOR (23 downto 0);
        data_rd     : out STD_LOGIC_VECTOR (15 downto 0);        
        data_wr     : in STD_LOGIC_VECTOR (15 downto 0);
        cmd_rdy     : out STD_LOGIC;                        
        wr_protect  : in STD_LOGIC;
        ce          : out STD_LOGIC;
        oe          : out STD_LOGIC;
        we          : out STD_LOGIC;       
        wp          : out STD_LOGIC;
        addr        : out STD_LOGIC_VECTOR (23 downto 0);
        qin         : in STD_LOGIC_VECTOR (15 downto 0);           
        qout        : out STD_LOGIC_VECTOR (15 downto 0);
        qdir        : out STD_LOGIC
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
    
    --Signals
    signal rom_qin_sig : std_logic_vector(15 downto 0) := (others =>'0');
    signal rom_qout_sig : std_logic_vector(15 downto 0) := (others =>'0');
    signal rom_qdir_sig : std_logic := '1';
    
    signal rom_en_sig : std_logic := '0';
    signal rom_cmd_sig : std_logic_vector(2 downto 0) := (others =>'0');
    signal rom_addr_sig : std_logic_vector(23 downto 0) := (others =>'0');
    signal rom_wr_data_sig : std_logic_vector(15 downto 0) := (others =>'0');
    signal rom_rd_data_sig : std_logic_vector(15 downto 0) := (others =>'0');    
    signal rom_cmd_rdy : std_logic := '0';
    signal rom_wrp_sig : std_logic := '0';
    
    
    signal u_din_sig  : std_logic_vector(7 downto 0) := (others => '0');
    signal u_dout_sig  : std_logic_vector(7 downto 0) := (others => '0');    
    signal u_load_sig  : std_logic := '0';         
    signal u_rdy_sig  : std_logic := '0';        
    signal u_busy_sig  : std_logic := '0';    
    signal u_err_sig   : std_logic := '0';
    
    type u_rx_type is ( 
        IDLE,
        READ                   
    );
    signal uart_rx_states : u_rx_type;
    
    signal byte_sig  : std_logic_vector(7 downto 0) := (others => '0');
    signal data_sig : std_logic := '0';
        
    type comm_type is ( 
        INIT,           
        CMD,
        ADDR,                   
        DATA,
        CLOSE,
        RD_DATA,
        CWAIT
    );
    signal comm : comm_type;

    signal count : integer range 0 to 6 := 0;

begin

    Inst_uart : uart PORT MAP 
    ( 
        clk_sys 		   => clk,
        rst                => rst,
        uart_baud_i        => "0011",
        uart_parity_i      => '0',
        uart_odd_even_i    => '0',  
        uart_ld_i          => u_load_sig,
        uart_tx_busy_o     => u_busy_sig,
        uart_din_i         => u_din_sig,
        uart_tx_o          => uart_tx_o,       
        uart_rx_rdy_o      => u_rdy_sig,
        uart_rx_i          => uart_rx_i,
        uart_dout_o        => u_dout_sig,
        uart_err_o         => u_err_sig,       
        uart_en_o          => uart_en_o 
    );
    
   Inst_usrmem : usrmem 
   PORT MAP
    ( 
        clk         => clk,
        rst         => rst,        
        en          => rom_en_sig, 
        cmd         => rom_cmd_sig,
        addr_in     => rom_addr_sig,
        data_rd     => rom_rd_data_sig,
        data_wr     => rom_wr_data_sig,
        cmd_rdy     => rom_cmd_rdy,
        wr_protect  => rom_wrp_sig,                               
        ce          => rom_ce,
        oe          => rom_oe,
        we          => rom_we,
        wp          => rom_wp,
        addr        => rom_addr,        
        qin         => rom_qin_sig,        
        qout        => rom_qout_sig,
        qdir        => rom_qdir_sig
    ); 

    rom_q <= rom_qout_sig when rom_qdir_sig = '0' else (others=>'Z');
    rom_qin_sig <= rom_q;   
    
    process (rst,clk) 
        variable ch : std_logic_vector(7 downto 0) := (others => '0');
    begin 
        if (rst = '0') then
            comm <= INIT;
            count <= 0;
        elsif (clk'event and clk = '1') then           
            case comm is
                when INIT =>                        
                    if data_sig = '1' then
                        if byte_sig = X"3E" then -- caracter ">" 
                         comm <= CMD;
                        end if;
                    end if;                        
                when CMD =>
                    if data_sig = '1' then
                        if byte_sig >= X"30" and byte_sig <= X"33" then
                            ch := byte_sig - X"30";
                            rom_cmd_sig <= ch(2 downto 0);     
                        end if;                        
                        case byte_sig is
                            when X"30" => --Comando RESET
                                comm <= CLOSE;
                            when X"31" => --Comando READ
                                comm <= ADDR;     
                                count <= 0;                       
                            when X"32" => --Comando PROGRAM
                                comm <= ADDR; 
                                count <= 0;        
                            when X"33" => --Comando ERASE
                                comm <= CLOSE;
                            when others =>
                                comm <= INIT;                                                        
                        end case;     
                    end if;
                when ADDR =>
                    if data_sig = '1' then                          
                        if byte_sig >= X"30" and byte_sig <= X"39" then
                            ch := byte_sig - X"30";
                            rom_addr_sig((23-(count*4)) downto (20-(count*4))) <= ch(3 downto 0); 
                        elsif byte_sig >= X"41" and byte_sig <= X"46" then  
                            ch := byte_sig - X"37";                     
                            rom_addr_sig((23-(count*4)) downto (20-(count*4))) <= ch(3 downto 0);                          
                        end if;                                                                          
                        count <= count + 1;  
                        if count = 5 then 
                            count <= 0; 
                            if rom_cmd_sig = B"001" then
                                comm <= CLOSE;
                            elsif rom_cmd_sig = B"010" then
                                comm <= DATA;                         
                            end if;                           
                        end if;
                    end if;                       
                when DATA =>
                    if data_sig = '1' then                    
                        if byte_sig >= X"30" and byte_sig <= X"39" then
                            ch := byte_sig - X"30"; 
                            rom_wr_data_sig((15-(count*4)) downto (12-(count*4))) <= ch(3 downto 0); 
                        elsif byte_sig >= X"41" and byte_sig <= X"46" then
                            ch := byte_sig - X"37";                           
                            rom_wr_data_sig((15-(count*4)) downto (12-(count*4))) <= ch(3 downto 0);                         
                        end if;
                        count <= count + 1;                        
                        if count = 3 then 
                            count <= 0; 
                            comm <= CLOSE;  
                        end if;
                    end if;                    
                when CLOSE =>
                    if data_sig = '1' then                    
                        if byte_sig = X"0A" then -- caracter "LF"                         
                            --Realizar proceso a memoria                           
                            if rom_cmd_sig = B"010" then
                                rom_wrp_sig <= '1';                        
                            else
                                rom_wrp_sig <= '0';                        
                            end if;                            
                            rom_en_sig <= '1'; 
                            comm <= CWAIT;
                        else 
                            --reseteo todos los parametros                            
                            comm <= INIT;                                       
                        end if;    
                    end if;
                when RD_DATA =>     
                    
                when CWAIT => 
                    rom_en_sig <= '0'; 
                    if rom_cmd_rdy = '1' then
                        rom_wrp_sig <= '0';
                        comm <= INIT;
                    end if;                      
                when others =>
            end case;           
        end if;
    end process;
    
    process (rst,clk) 
    begin 
        if (rst = '0') then
            uart_rx_states <= IDLE;
            byte_sig <= (others => '0');
            data_sig <= '0';
        elsif (clk'event and clk = '1') then
            case uart_rx_states is
                when IDLE =>
                    if u_rdy_sig = '1' then
                        byte_sig <= u_dout_sig;
                        uart_rx_states <= READ;                         
                    end if;
                    data_sig <= '0';
                when READ =>
                    if u_rdy_sig = '0' then
                        uart_rx_states <= IDLE;  
                        data_sig <= '1';                       
                    end if;     
                when others =>
            end case;
        end if;
    end process;
        
end Behavioral;