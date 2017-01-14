library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ann_v2_0_Inputs_S_AXIS is
	generic (
		-- Users to add parameters here
      RD_WIDTH : natural := 8;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
      fifo_rd : out std_logic;
      fifo_rdata : out std_logic_vector(RD_WIDTH-1 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end ann_v2_0_Inputs_S_AXIS;

architecture arch_imp of ann_v2_0_Inputs_S_AXIS is

begin
   -- I/O Connections assignments
   --fifo_rdata <= S_AXIS_TDATA(RD_WIDTH-1 downto 0);
   S_AXIS_TREADY <= '1'; -- Se podría esperar a que se cargasen todos los pesos, pero prefiero que sea el SW el que se encargue de asegurarlo.
   --fifo_rd <= S_AXIS_TVALID;
   
   process (S_AXIS_ACLK) -- Register inputs, mey be not necesary.
   begin
     if ( rising_edge(S_AXIS_ACLK) ) then
       if ( S_AXIS_ARESETN = '0' ) then
         --S_AXIS_TREADY <= '0';
         fifo_rd <= '0';
         fifo_rdata <= (others => '0');
       else
         fifo_rdata <= S_AXIS_TDATA(RD_WIDTH-1 downto 0);
         fifo_rd <= S_AXIS_TVALID;
       end if;
     end if;
   end process;

end arch_imp;
