----------------------------------------------------------------------------------
-- Company: GEO Tecnologies SAS
-- Engineer: Jairo Mena Muñoz
-- 
-- Create Date: 25.10.2018 15:25:53
-- Design Name: Memoria de Usuario Prueba unitaria - Módulo UsrMem
-- Module Name: usrmem - Behavioral
-- Project Name: Prueba Unitaria UsrMem  
-- Target Devices: GEO-HCAL-1.0.0
-- Tool Versions: 1.0.0 
-- Description: Módulo que gestiona las señales conectadas hacia la memoria Flash con puerto paralelo de usuario.  
--              El puerto de datos Q0-Q15 es un puerto biridiccional de lectura y escritura.
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

entity usrmem is
    Port ( 
       clk : in STD_LOGIC;
       rst : in STD_LOGIC;       
       en : in STD_LOGIC;
       cmd : in STD_LOGIC_VECTOR (2 downto 0);
       addr_in : in STD_LOGIC_VECTOR (23 downto 0);
       data_rd : out STD_LOGIC_VECTOR (15 downto 0);
       data_wr : in STD_LOGIC_VECTOR (15 downto 0);
       cmd_rdy : out STD_LOGIC;
       wr_protect : in STD_LOGIC;                    
       ce : out STD_LOGIC;
       oe : out STD_LOGIC;
       we : out STD_LOGIC;
       wp : out STD_LOGIC;
       byte : out STD_LOGIC;
       addr : out STD_LOGIC_VECTOR (23 downto 0);
       qin : in STD_LOGIC_VECTOR (15 downto 0);           
       qout : out STD_LOGIC_VECTOR (15 downto 0);
       qdir : out STD_LOGIC       
       );
end usrmem;

architecture Behavioral of usrmem is

    signal ce_sig    : std_logic := '1';
    signal oe_sig    : std_logic := '1';
    signal we_sig    : std_logic := '1';  
    signal addr_sig  : STD_LOGIC_VECTOR (23 downto 0) := (others =>'0');       
    signal qin_sig   : STD_LOGIC_VECTOR (15 downto 0) := (others =>'0');  
    signal qout_sig  : STD_LOGIC_VECTOR (15 downto 0) := (others =>'0'); 
    
    signal qdir_sig   : std_logic := '1';
    
    signal cycle_en_sig    : std_logic := '0';
    signal cycle_mod_sig   : std_logic := '0';
    signal cycle_rdy_sig   : std_logic := '0';

    signal addr_word  : STD_LOGIC_VECTOR (23 downto 0) := (others =>'0');
    signal data_word  : STD_LOGIC_VECTOR (15 downto 0) := (others =>'0');
    signal cmd_rdy_sig  : std_logic := '0';
    
    type word_states is (
        STANDBY,
        
        RS_1CYCLE,
        
        RD_1CYCLE,
                
        WR_1CYCLE,
        WR_2CYCLE,
        WR_3CYCLE,
        WR_4CYCLE,
 
        ER_1CYCLE,
        ER_2CYCLE,
        ER_3CYCLE,
        ER_4CYCLE,
        ER_5CYCLE,
        ER_6CYCLE,
                
        RDY_STD,                              
        STATE_WAIT
    );
    signal state_word, state_return : word_states;
    
    type cmd_states is (
        STANDBY,
        
        RD_OE,
        RD_DATA,
        RD_RDY, 
        RD_RET, 

        WR_WE,
        WR_DATA,
        WR_RDY,
        WR_RET        
    );
    signal state_cmd : cmd_states;

    constant MAX_TIME : integer := 10;
    signal cnt_time : integer range 0 to MAX_TIME := 0;
        
begin

    ce <= ce_sig;
    oe <= oe_sig;
    we <= we_sig;

    wp <= wr_protect;
    addr <= addr_sig;
    qout <= qout_sig;
    qdir <= qdir_sig;

    data_rd <= qin_sig;
    cmd_rdy <= cmd_rdy_sig;
     
   process (rst,clk) 
    begin 
        if rst = '0' then
            
            addr_sig <= (others =>'0');
            qout_sig <= (others =>'0');
            
            cycle_en_sig <= '0';            
            cycle_mod_sig <= '0';
            cmd_rdy_sig <= '0';
            
            state_word <= STANDBY;
            state_return <= STATE_WAIT;
            
            addr_word <= (others =>'0');
            data_word <= (others =>'0'); 
                                
        elsif clk'event and clk = '1' then            
            
            case state_word is           
                when STANDBY =>
                    cmd_rdy_sig <= '0';
                    if en = '1' then                       
                        case cmd is           
                            when "000" =>
                                state_word <= RS_1CYCLE;
                            when "001" => 
                                state_word <= RD_1CYCLE; 
                                addr_word <= addr_in;                                                                                 
                            when "010" =>
                                state_word <= WR_1CYCLE;
                                addr_word <= addr_in;
                                data_word <= data_wr;
                            when "011" =>
                                state_word <= ER_1CYCLE;
                                addr_word <= addr_in;                                                               
                            when others =>                                      
                        end case;                    
                    end if;
                
                --CMD "000"  Reset Mode                      
                when RS_1CYCLE =>
                    addr_sig <= X"000000";
                    qout_sig <= X"00F0";
                    cycle_en_sig <= '1';  
                    cycle_mod_sig <= '1';
                    state_return <= RDY_STD;
                    state_word <= STATE_WAIT;               

                --CMD "001"  Read Mode                     
                when RD_1CYCLE =>
                    addr_sig <= addr_word;
                    cycle_en_sig <= '1';  
                    cycle_mod_sig <= '0';
                    state_return <= RDY_STD;
                    state_word <= STATE_WAIT;
                                        
                --CMD "010"  Program Mode
                when WR_1CYCLE =>
                    addr_sig <= X"000555";
                    qout_sig <= X"00AA";
                    cycle_en_sig <= '1';  
                    cycle_mod_sig <= '1';
                    state_return <= WR_2CYCLE;
                    state_word <= STATE_WAIT;
                when WR_2CYCLE =>
                    addr_sig <= X"0002AA";
                    qout_sig <= X"0055";
                    cycle_en_sig <= '1';  
                    cycle_mod_sig <= '1';
                    state_return <= WR_3CYCLE;
                    state_word <= STATE_WAIT;
                when WR_3CYCLE =>
                    addr_sig <= X"000555";
                    qout_sig <= X"00A0";
                    cycle_en_sig <= '1';  
                    cycle_mod_sig <= '1';
                    state_return <= WR_4CYCLE;
                    state_word <= STATE_WAIT;
                when WR_4CYCLE =>
                    addr_sig <= addr_word;
                    qout_sig <= data_word;                     
                    cycle_en_sig <= '1';  
                    cycle_mod_sig <= '1';
                    state_return <= RDY_STD;
                    state_word <= STATE_WAIT;

                --CMD "011"  Chip Erase
                when ER_1CYCLE =>
                     addr_sig <= X"000555";
                     qout_sig <= X"00AA";
                     cycle_en_sig <= '1';  
                     cycle_mod_sig <= '1';
                     state_return <= ER_2CYCLE;
                     state_word <= STATE_WAIT;
                 when ER_2CYCLE =>
                     addr_sig <= X"0002AA";
                     qout_sig <= X"0055";
                     cycle_en_sig <= '1';  
                     cycle_mod_sig <= '1';
                     state_return <= ER_3CYCLE;
                     state_word <= STATE_WAIT;
                 when ER_3CYCLE =>
                     addr_sig <= X"000555";
                     qout_sig <= X"0080";
                     cycle_en_sig <= '1';  
                     cycle_mod_sig <= '1';
                     state_return <= ER_4CYCLE;
                     state_word <= STATE_WAIT;
                 when ER_4CYCLE =>
                     addr_sig <= X"000555";
                     qout_sig <= X"00AA";
                     cycle_en_sig <= '1';  
                     cycle_mod_sig <= '1';
                     state_return <= ER_5CYCLE;
                     state_word <= STATE_WAIT;
                 when ER_5CYCLE =>
                     addr_sig <= X"0002AA";
                     qout_sig <= X"0055";
                     cycle_en_sig <= '1';  
                     cycle_mod_sig <= '1';
                     state_return <= ER_6CYCLE;
                     state_word <= STATE_WAIT;
                 when ER_6CYCLE =>
                     addr_sig <= X"000555";
                     qout_sig <= X"0010";
                     cycle_en_sig <= '1';  
                     cycle_mod_sig <= '1';
                     state_return <= RDY_STD;
                     state_word <= STATE_WAIT;                                                  
                
                when RDY_STD =>
                    cmd_rdy_sig <= '1';
                    state_word <= STANDBY;                                                                                                                                         
                when STATE_WAIT =>
                    cycle_en_sig <= '0';
                    if cycle_rdy_sig = '1' then                                  
                        state_word <= state_return;
                    end if;                                                                                                                                                                                                                               
                when others =>                                     
            end case;                      
               
        end if;
    end process;

        
    process (rst,clk) 
    begin 
        if rst = '0' then
            ce_sig <= '1';
            oe_sig <= '1';
            we_sig <= '1';        
            qdir_sig <= '1';
            state_cmd <= STANDBY;
            cnt_time <= 0; 
            cycle_rdy_sig <= '0';
            qin_sig <= (others =>'0');                    
        elsif clk'event and clk = '1' then            
            
            case state_cmd is           
                when STANDBY =>
                    cycle_rdy_sig <= '0';
                    if cycle_en_sig = '1' then
                        ce_sig <= '0';
                        cnt_time <= 0;
                        if cycle_mod_sig = '0' then
                            state_cmd <= RD_OE;    
                        else
                            state_cmd <= WR_WE;
                        end if;
                    end if;
                                       
                when RD_OE =>     
                    oe_sig <= '0';                                       
                    if cnt_time = 6 then                    
                        state_cmd <= RD_DATA;                
                        cnt_time <= 0;      
                    else
                        cnt_time <= cnt_time + 1;
                    end if;                                         
                when RD_DATA =>                       
                    cycle_rdy_sig <= '1';
                    state_cmd <=  RD_RET;
                when RD_RET =>
                    qin_sig <= qin;
                    ce_sig <= '1';
                    oe_sig <= '1';
                    cycle_rdy_sig <= '0';                          
                    state_cmd <= STANDBY;                                                                             
                                              
                when WR_WE =>
                    we_sig <= '0';
                    qdir_sig <= '0';
                    if cnt_time = 5 then                   
                        state_cmd <= WR_DATA;
                        cnt_time <= 0;    
                    else
                        cnt_time <= cnt_time + 1;
                    end if;  
                when WR_DATA =>
                    we_sig <= '1';
                    state_cmd <= WR_RDY;
                when WR_RDY =>                      
                    if cnt_time = 5 then 
                        cnt_time <= 0;  
                        cycle_rdy_sig <= '1';
                        state_cmd <= WR_RET;                          
                    else
                        cnt_time <= cnt_time + 1;
                    end if;                  
                when WR_RET =>
                    qdir_sig <= '1';
                    ce_sig <= '1';  
                    cycle_rdy_sig <= '0';                                      
                    state_cmd <= STANDBY;
                                                                                                                            
                when others =>                                     
            end case;                      
               
        end if;
    end process;
    
end Behavioral;
