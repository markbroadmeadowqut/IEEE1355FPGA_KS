----------------------------------------------------------------------------------
-- Project:             Final Year Project     
-- Engineer:            Ken Sands
-- Create Date:         29.03.2016 12:01:16
-- Design Name:         Node
-- Module Name:         Top Design
-- Project Name:        High Speed Coms Bus Using FPGA
-- Target Devices:      Artix 7
-- Description:         Top end of node design.  
-- Dependencies:  
-- Revision:            1
-- Additional Comments: 
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
library UNISIM;    
    use UNISIM.VComponents.all;
library WORK;
    use work.bus_pkg.all;

entity node is
    generic ( 
        -- this field indicates the type of node that is generated. it alters the 
        -- packet layer according to following inputs. "slave" produces a general
        -- node for the use in the field. "master produces a terminal "master
        --  produces a terminal node with pushbutton inputs.
        packet      : node_type := slave
    );
	port (
		clk_pad   : in  std_logic;						-- System clock
        rst_n     : in  std_logic;                      -- "reset" button input                
        sw        : in  std_logic_vector(3 downto 0);   -- 4 switches on FPGA board    
        btn       : in  std_logic_vector(3 downto 0);   -- 4 buttons on fpga board        
        A_d_in_P  : in  std_logic;                      -- Side A data in pin
        A_d_in_N  : in  std_logic;                       
        A_s_in_P  : in  std_logic;                      -- Side A strobe in pin 
        A_s_in_N  : in  std_logic;                       
        B_d_in_P  : in  std_logic;                      -- Side B data in pin
        B_d_in_N  : in  std_logic;                        
        B_s_in_P  : in  std_logic;                      -- Side B strobe in pin
        B_s_in_N  : in  std_logic;                                      
        led       : out std_logic_vector(3 downto 0);   -- 4 LEDs on FPGA board        
        ledb      : out std_logic_vector(3 downto 0);   -- 4 blue LEDs on FPGA board        
        A_d_out_P : out std_logic;                      -- Side A data out pin
        A_d_out_N : out std_logic;                      
        A_s_out_P : out std_logic;                      -- Side A strobe out pin
        A_s_out_N : out std_logic;                      
        B_d_out_P : out std_logic;                      -- Side B data out pin
        B_d_out_N : out std_logic;                      
        B_s_out_P : out std_logic;                      -- Side B strobe out pin
        B_s_out_N : out std_logic;                      
        debug     : out std_logic_vector(35 downto 0)   -- debug signal branches to  
	);                                                  -- all lowest level of node           
end node;

architecture RTL of node is

    -- clocks
	signal clk_tx       : std_logic;                -- transmitter clock 
	signal clk_rx       : std_logic;                -- receiver clock must be 
	                                                -- 1.5 times faster than tx clock
    -- data signals
    signal display      : std_logic_vector(7 downto 0); 
                                                    -- output to led's for debugging
    signal d_inA           : std_logic;             -- Raw data signal to side A
    signal s_inA           : std_logic;             -- Raw strobe signal to side A
    signal d_outA          : std_logic;             -- Raw data signal from side A
    signal s_outA          : std_logic;             -- Raw strobe signal from side A
    signal d_inB           : std_logic;             -- Raw data signal to side B
    signal s_inB           : std_logic;             -- Raw strobe signal to side B
    signal d_outB          : std_logic;             -- Raw data signal from side B
    signal s_outB          : std_logic;             -- Raw strobe signal from side B
    --signal du           : std_logic;              -- signals to connect IO internally
    --signal su           : std_logic;              -- signals to connect IO internally
            
    -- Records
    signal ExPktA       : ExPkt_rec;                -- Exchange layer to packet layer records
    signal ExPktB       : ExPkt_rec;                    -- Side A and B
    signal PktExA       : PktEx_rec;                -- Packet layer to exchange layer records
    signal PktExB       : PktEx_rec;                    -- Side A and B
    
    -- components
    component pll                                   -- pll clock creation component
        port (
            sys_clk     : in     std_logic;         -- Clock in port
            clk_tx      : out    std_logic;         -- Clock out ports
            clk_rx      : out    std_logic
         );
        end component;        
begin

 
TXRX_clks : pll                                     -- Instantiation of PLL from IP library
    port map ( 
       sys_clk => clk_pad,       
        clk_tx  => clk_tx,          
        clk_rx  => clk_rx              
    );
                 
Side_A: entity work.side                            -- instantiate Side A of node     
        
    port map ( 
        clk_tx          => clk_tx,
        clk_rx          => clk_rx,                       
        rst_n           => rst_n,
        d_in            => d_inA, --dd, 
        s_in            => s_inA, --sd, 
        PktEx           => PktExA,
        d_out           => d_outA, --du, 
        s_out           => s_outA, --su,  
        ExPkt           => ExPktA,
        debug           => debug
        );        
        
Side_B: entity work.side                            -- instantiate Side B of node
    port map ( 
        clk_tx          => clk_tx,
        clk_rx          => clk_rx,                       
        rst_n           => rst_n,
        d_in            => d_inB, --du, 
        s_in            => s_inB, --su, 
        PktEx           => PktExB,
        d_out           => d_outB, --dd, 
        s_out           => s_outB, --sd, 
        ExPkt           => ExPktB,
        debug           => open
        );         

packet_sel0: if packet = slave generate
    pkt_slave_ins: entity work.packet               -- instantiate common packet layer 
    port map (                                      -- This packet layer forms a normal    
        wr_clk          => clk_rx,                  -- node as outlined by the project 
        rd_clk          => clk_tx,
        rst_n           => rst_n,
        sw              => sw,
        btn             => btn,
        ExPktA          => ExPktA,        
        ExPktB          => ExPktB,          
        display         => display,
        PktExA          => PktExA, 
        PktExB          => PktExB       
        );
end generate;               

packet_sel1: if packet = master generate
    pkt_master_ins: entity work.pkt_master          -- instantiate common packet layer                                                 
    port map (                                      -- This packet layer forms a terminal 
        wr_clk          => clk_rx,                  -- for testing purposes, it establishes  
        rd_clk          => clk_tx,                  -- links and fills a register from on 
        rst_n           => rst_n,                   -- board buttons and switches to simulate
        sw              => sw,                      -- the transmission of data.
        btn             => btn,
        ExPktA          => ExPktA,        
        ExPktB          => ExPktB,          
        display         => display,
        PktExA          => PktExA, 
        PktExB          => PktExB         
        );
end generate; 

-- Generation of positive and negative signals for DE signalling
-- ports are JB and JC pmods for A side, and B side respectively

data_out_A : OBUFDS
    generic map (
        --IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
        SLEW => "SLOW") -- Specify the output slew rate 
    port map(
        I  => d_outA, -- Buffer output
        O  => A_d_out_p,
        OB => A_d_out_n
    );
  
strobe_out_A : OBUFDS
    generic map (
        --IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
        SLEW => "SLOW") -- Specify the output slew rate  
    port map(
        I  => s_outA, -- Buffer output
        O  => A_s_out_p,
        OB => A_s_out_n
    );  

data_out_B : OBUFDS
    generic map (
        --IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
        SLEW => "SLOW") -- Specify the output slew rate  
    port map(
        I  => d_outB, -- Buffer output
        O  => B_d_out_p,
        OB => B_d_out_n
    );  
    
strobe_out_B : OBUFDS
    generic map (
        --IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
        SLEW => "SLOW") -- Specify the output slew rate 
    port map(
        I  => s_outB, -- Buffer output
        O  => B_s_out_p,
        OB => B_s_out_n
    );  
    
    
data_in_A : IBUFDS 
    generic map (
        DIFF_TERM => FALSE, -- Differential Termination
        IBUF_LOW_PWR => TRUE -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        --IOSTANDARD => " T"
        )
    port map(
        O  => d_inA, -- Buffer output
        I  => A_d_in_p,
        IB => A_d_in_n
    );
      
strobe_in_A : IBUFDS 
    generic map (
        DIFF_TERM => FALSE, -- Differential Termination
        IBUF_LOW_PWR => TRUE -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        --IOSTANDARD => "DEFAULT"
        )
    port map(
        O  => s_inA, -- Buffer output
        I  => A_s_in_p,
        IB => A_s_in_n
    );  
    
data_in_B : IBUFDS 
    generic map (
        DIFF_TERM => FALSE, -- Differential Termination
        IBUF_LOW_PWR => TRUE -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        --IOSTANDARD => "DEFAULT"
        )
    port map(
        O  => d_inB, -- Buffer output
        I  => B_d_in_p,
        IB => B_d_in_n
    );  
        
strobe_in_B : IBUFDS 
    generic map (
        DIFF_TERM => FALSE, -- Differential Termination
        IBUF_LOW_PWR => TRUE -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        --IOSTANDARD => "DEFAULT"
        )
    port map(
        O  => s_inB, -- Buffer output
        I  => B_s_in_p,
        IB => B_s_in_n
    );      
            
            
	led       <= display(7 downto 4);
	ledb      <= display(3 downto 0);
	
end RTL;



