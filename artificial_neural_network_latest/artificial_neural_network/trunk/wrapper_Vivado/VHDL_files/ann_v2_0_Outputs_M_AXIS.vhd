library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ann_v2_0_Outputs_M_AXIS is
	generic (
		-- Users to add parameters here
      WR_WIDTH : natural := 8; -- Bit width for Write data
      NUMBER_OF_OUTPUT_WORDS : integer := 8; -- Total number of output data.
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
      fifo_wr : in std_logic;
      fifo_wdata : in std_logic_vector(WR_WIDTH-1 downto 0); -- Nota: recordar utilizar sxt() -sign extension- al enviar por AXI
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		M_AXIS_ACLK	: in std_logic;
		-- 
		M_AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
end ann_v2_0_Outputs_M_AXIS;

architecture implementation of ann_v2_0_Outputs_M_AXIS is

   signal counter : integer range 0 to NUMBER_OF_OUTPUT_WORDS-1;

begin
   -- I/O Connections assignments
   M_AXIS_TSTRB <= (others => '1');
   M_AXIS_TVALID <= fifo_wr;
   M_AXIS_TDATA <= std_logic_vector(resize(signed(fifo_wdata),C_M_AXIS_TDATA_WIDTH));
   M_AXIS_TLAST <= '1' when ( counter = (NUMBER_OF_OUTPUT_WORDS-1) ) else '0';
   
   process (M_AXIS_ACLK)
   begin
      if ( rising_edge(M_AXIS_ACLK) ) then
         if ( M_AXIS_ARESETN = '0' ) then
            counter <= 0;
         else
            if (fifo_wr = '1') then
               if counter = NUMBER_OF_OUTPUT_WORDS-1 then
                  counter <= 0;
               else
                  counter <= counter +1;
               end if;
            end if;
         end if;
      end if;
   end process;

end implementation;
