library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.layers_pkg.all;

entity ann_v2_0 is
   generic (
      -- Users to add parameters here
      Nlayer   : integer := 4;     ------------ Number of layers in the ANN
      NbitW    : natural := 16;    ------------ Bit width of wieghts and biases
      NbitIn   : natural := 8;     ------------ Bit width of the inputs
      NbitOut  : natural := 8;     ------------ Bit width of the network output
      NumIn    : natural := 16;    ------------ Number of inputs to the network
      NumN     : string  := "8 2 8 16";  ------ Number of neurons in each layer
      l_type   : string  := "SP PS SP PS";  --- Layer type
      f_type   : string  := "siglu2 linear siglut linear"; -- Activation function type of each layer
      LSbit    : string  := "12 12 12 12";   -- LSB of the output of each layer
      NbitO    : string  := "12 8 12 8";   ---- Bit width of the outputs of each layer. The last one should match with NbitOut
      -- User parameters ends
      -- Do not modify the parameters beyond this line


      -- Parameters of Axi Slave Bus Interface Inputs_S_AXIS
      C_Inputs_S_AXIS_TDATA_WIDTH   : integer   := 32;

      -- Parameters of Axi Master Bus Interface Outputs_M_AXIS
      C_Outputs_M_AXIS_TDATA_WIDTH   : integer   := 32;
      C_Outputs_M_AXIS_START_COUNT   : integer   := 32;

      -- Parameters of Axi Slave Bus Interface Wyb_S_AXI
      C_Wyb_S_AXI_ID_WIDTH   : integer   := 1;
      C_Wyb_S_AXI_DATA_WIDTH   : integer   := 32;
      C_Wyb_S_AXI_ADDR_WIDTH   : integer   := 12;
      C_Wyb_S_AXI_AWUSER_WIDTH   : integer   := 0;
      C_Wyb_S_AXI_ARUSER_WIDTH   : integer   := 0;
      C_Wyb_S_AXI_WUSER_WIDTH   : integer   := 0;
      C_Wyb_S_AXI_RUSER_WIDTH   : integer   := 0;
      C_Wyb_S_AXI_BUSER_WIDTH   : integer   := 0
   );
   port (
      -- Users to add ports here
      ann_areset : in std_logic;
      -- User ports ends
      -- Do not modify the ports beyond this line


      -- Ports of Axi Slave Bus Interface Inputs_S_AXIS
      inputs_s_axis_aclk   : in std_logic;
      inputs_s_axis_aresetn   : in std_logic;
      inputs_s_axis_tready   : out std_logic;
      inputs_s_axis_tdata   : in std_logic_vector(C_Inputs_S_AXIS_TDATA_WIDTH-1 downto 0);
      inputs_s_axis_tstrb   : in std_logic_vector((C_Inputs_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
      inputs_s_axis_tlast   : in std_logic;
      inputs_s_axis_tvalid   : in std_logic;

      -- Ports of Axi Master Bus Interface Outputs_M_AXIS
      outputs_m_axis_aclk   : in std_logic;
      outputs_m_axis_aresetn   : in std_logic;
      outputs_m_axis_tvalid   : out std_logic;
      outputs_m_axis_tdata   : out std_logic_vector(C_Outputs_M_AXIS_TDATA_WIDTH-1 downto 0);
      outputs_m_axis_tstrb   : out std_logic_vector((C_Outputs_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
      outputs_m_axis_tlast   : out std_logic;
      outputs_m_axis_tready   : in std_logic;

      -- Ports of Axi Slave Bus Interface Wyb_S_AXI
      wyb_s_axi_aclk   : in std_logic;
      wyb_s_axi_aresetn   : in std_logic;
      wyb_s_axi_awid   : in std_logic_vector(C_Wyb_S_AXI_ID_WIDTH-1 downto 0);
      wyb_s_axi_awaddr   : in std_logic_vector(C_Wyb_S_AXI_ADDR_WIDTH-1 downto 0);
      wyb_s_axi_awlen   : in std_logic_vector(7 downto 0);
      wyb_s_axi_awsize   : in std_logic_vector(2 downto 0);
      wyb_s_axi_awburst   : in std_logic_vector(1 downto 0);
      wyb_s_axi_awlock   : in std_logic;
      wyb_s_axi_awcache   : in std_logic_vector(3 downto 0);
      wyb_s_axi_awprot   : in std_logic_vector(2 downto 0);
      wyb_s_axi_awqos   : in std_logic_vector(3 downto 0);
      wyb_s_axi_awregion   : in std_logic_vector(3 downto 0);
      wyb_s_axi_awuser   : in std_logic_vector(C_Wyb_S_AXI_AWUSER_WIDTH-1 downto 0);
      wyb_s_axi_awvalid   : in std_logic;
      wyb_s_axi_awready   : out std_logic;
      wyb_s_axi_wdata   : in std_logic_vector(C_Wyb_S_AXI_DATA_WIDTH-1 downto 0);
      wyb_s_axi_wstrb   : in std_logic_vector((C_Wyb_S_AXI_DATA_WIDTH/8)-1 downto 0);
      wyb_s_axi_wlast   : in std_logic;
      wyb_s_axi_wuser   : in std_logic_vector(C_Wyb_S_AXI_WUSER_WIDTH-1 downto 0);
      wyb_s_axi_wvalid   : in std_logic;
      wyb_s_axi_wready   : out std_logic;
      wyb_s_axi_bid   : out std_logic_vector(C_Wyb_S_AXI_ID_WIDTH-1 downto 0);
      wyb_s_axi_bresp   : out std_logic_vector(1 downto 0);
      wyb_s_axi_buser   : out std_logic_vector(C_Wyb_S_AXI_BUSER_WIDTH-1 downto 0);
      wyb_s_axi_bvalid   : out std_logic;
      wyb_s_axi_bready   : in std_logic;
      wyb_s_axi_arid   : in std_logic_vector(C_Wyb_S_AXI_ID_WIDTH-1 downto 0);
      wyb_s_axi_araddr   : in std_logic_vector(C_Wyb_S_AXI_ADDR_WIDTH-1 downto 0);
      wyb_s_axi_arlen   : in std_logic_vector(7 downto 0);
      wyb_s_axi_arsize   : in std_logic_vector(2 downto 0);
      wyb_s_axi_arburst   : in std_logic_vector(1 downto 0);
      wyb_s_axi_arlock   : in std_logic;
      wyb_s_axi_arcache   : in std_logic_vector(3 downto 0);
      wyb_s_axi_arprot   : in std_logic_vector(2 downto 0);
      wyb_s_axi_arqos   : in std_logic_vector(3 downto 0);
      wyb_s_axi_arregion   : in std_logic_vector(3 downto 0);
      wyb_s_axi_aruser   : in std_logic_vector(C_Wyb_S_AXI_ARUSER_WIDTH-1 downto 0);
      wyb_s_axi_arvalid   : in std_logic;
      wyb_s_axi_arready   : out std_logic;
      wyb_s_axi_rid   : out std_logic_vector(C_Wyb_S_AXI_ID_WIDTH-1 downto 0);
      wyb_s_axi_rdata   : out std_logic_vector(C_Wyb_S_AXI_DATA_WIDTH-1 downto 0);
      wyb_s_axi_rresp   : out std_logic_vector(1 downto 0);
      wyb_s_axi_rlast   : out std_logic;
      wyb_s_axi_ruser   : out std_logic_vector(C_Wyb_S_AXI_RUSER_WIDTH-1 downto 0);
      wyb_s_axi_rvalid   : out std_logic;
      wyb_s_axi_rready   : in std_logic
   );
end ann_v2_0;

architecture arch_imp of ann_v2_0 is

   -- component declaration
   component ann_v2_0_Inputs_S_AXIS is
      generic (
         RD_WIDTH : natural := 8;
         C_S_AXIS_TDATA_WIDTH   : integer   := 32
      );
      port (
         fifo_rd : out std_logic;
         fifo_rdata : out std_logic_vector(RD_WIDTH-1 downto 0);
         S_AXIS_ACLK   : in std_logic;
         S_AXIS_ARESETN   : in std_logic;
         S_AXIS_TREADY   : out std_logic;
         S_AXIS_TDATA   : in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
         S_AXIS_TSTRB   : in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
         S_AXIS_TLAST   : in std_logic;
         S_AXIS_TVALID   : in std_logic
      );
   end component ann_v2_0_Inputs_S_AXIS;

   component ann_v2_0_Outputs_M_AXIS is
      generic (
         WR_WIDTH : natural := 8;
         NUMBER_OF_OUTPUT_WORDS : integer := 8;
         C_M_AXIS_TDATA_WIDTH   : integer   := 32
      );
      port (
         fifo_wr : in std_logic;
         fifo_wdata : in std_logic_vector(WR_WIDTH-1 downto 0);
         M_AXIS_ACLK   : in std_logic;
         M_AXIS_ARESETN   : in std_logic;
         M_AXIS_TVALID   : out std_logic;
         M_AXIS_TDATA   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
         M_AXIS_TSTRB   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
         M_AXIS_TLAST   : out std_logic;
         M_AXIS_TREADY   : in std_logic
      );
   end component ann_v2_0_Outputs_M_AXIS;

   component ann_v2_0_Wyb_S_AXI is
      generic (
         ADDR_WIDTH : integer;
         DATA_WIDTH : integer := 16;
         C_S_AXI_ID_WIDTH   : integer   := 1;
         C_S_AXI_DATA_WIDTH   : integer   := 32;
         C_S_AXI_ADDR_WIDTH   : integer   := 10;
         C_S_AXI_AWUSER_WIDTH   : integer   := 0;
         C_S_AXI_ARUSER_WIDTH   : integer   := 0;
         C_S_AXI_WUSER_WIDTH   : integer   := 0;
         C_S_AXI_RUSER_WIDTH   : integer   := 0;
         C_S_AXI_BUSER_WIDTH   : integer   := 0
      );
      port (
         m_en : out std_logic;
         m_we : out std_logic_vector(((DATA_WIDTH+7)/8)-1 downto 0);
         wdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
         addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
         rdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
         S_AXI_ACLK   : in std_logic;
         S_AXI_ARESETN   : in std_logic;
         S_AXI_AWID   : in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
         S_AXI_AWADDR   : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
         S_AXI_AWLEN   : in std_logic_vector(7 downto 0);
         S_AXI_AWSIZE   : in std_logic_vector(2 downto 0);
         S_AXI_AWBURST   : in std_logic_vector(1 downto 0);
         S_AXI_AWLOCK   : in std_logic;
         S_AXI_AWCACHE   : in std_logic_vector(3 downto 0);
         S_AXI_AWPROT   : in std_logic_vector(2 downto 0);
         S_AXI_AWQOS   : in std_logic_vector(3 downto 0);
         S_AXI_AWREGION   : in std_logic_vector(3 downto 0);
         S_AXI_AWUSER   : in std_logic_vector(C_S_AXI_AWUSER_WIDTH-1 downto 0);
         S_AXI_AWVALID   : in std_logic;
         S_AXI_AWREADY   : out std_logic;
         S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
         S_AXI_WSTRB   : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
         S_AXI_WLAST   : in std_logic;
         S_AXI_WUSER   : in std_logic_vector(C_S_AXI_WUSER_WIDTH-1 downto 0);
         S_AXI_WVALID   : in std_logic;
         S_AXI_WREADY   : out std_logic;
         S_AXI_BID   : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
         S_AXI_BRESP   : out std_logic_vector(1 downto 0);
         S_AXI_BUSER   : out std_logic_vector(C_S_AXI_BUSER_WIDTH-1 downto 0);
         S_AXI_BVALID   : out std_logic;
         S_AXI_BREADY   : in std_logic;
         S_AXI_ARID   : in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
         S_AXI_ARADDR   : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
         S_AXI_ARLEN   : in std_logic_vector(7 downto 0);
         S_AXI_ARSIZE   : in std_logic_vector(2 downto 0);
         S_AXI_ARBURST   : in std_logic_vector(1 downto 0);
         S_AXI_ARLOCK   : in std_logic;
         S_AXI_ARCACHE   : in std_logic_vector(3 downto 0);
         S_AXI_ARPROT   : in std_logic_vector(2 downto 0);
         S_AXI_ARQOS   : in std_logic_vector(3 downto 0);
         S_AXI_ARREGION   : in std_logic_vector(3 downto 0);
         S_AXI_ARUSER   : in std_logic_vector(C_S_AXI_ARUSER_WIDTH-1 downto 0);
         S_AXI_ARVALID   : in std_logic;
         S_AXI_ARREADY   : out std_logic;
         S_AXI_RID   : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
         S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
         S_AXI_RRESP   : out std_logic_vector(1 downto 0);
         S_AXI_RLAST   : out std_logic;
         S_AXI_RUSER   : out std_logic_vector(C_S_AXI_RUSER_WIDTH-1 downto 0);
         S_AXI_RVALID   : out std_logic;
         S_AXI_RREADY   : in std_logic
      );
   end component ann_v2_0_Wyb_S_AXI;

   -- User declarations:
   constant NumN_v  : int_vector(Nlayer-1 downto 0) := assign_ints(NumN,Nlayer);
   constant LSbit_v : int_vector(Nlayer-1 downto 0) := assign_ints(LSbit,Nlayer);
   constant NbitO_v : int_vector(Nlayer-1 downto 0) := assign_ints(NbitO,Nlayer);

   signal run_in  : std_logic; -- Start and input data enable
   signal run_out : std_logic; -- Output data validation
   signal rdata   : std_logic_vector(NbitW-1 downto 0);   -- Read data for weights and biases memory
   signal wdata   : std_logic_vector(NbitW-1 downto 0);   -- Write data for weights and biases memory
   signal outputs : std_logic_vector(NbitOut-1 downto 0); -- Output data of the ANN
   --signal outs01  : std_logic_vector(Nbit01-1 downto 0);  -- Output data of each layer
   signal inputs  : std_logic_vector(NbitIn-1 downto 0);  -- Input data

   signal ANN_addr : std_logic_vector((calculate_addr_l(NumIn, NumN_v, Nlayer)+log2(Nlayer))-1 downto 0); -- nuevo

   signal m_en    : std_logic; -- Weight and biases memory enable
   signal m_we    : std_logic_vector(((NbitW+7)/8)-1 downto 0); -- Byte write enable of wieght and biases memory

begin

-- Instantiation of Axi Bus Interface Inputs_S_AXIS
ann_v2_0_Inputs_S_AXIS_inst : ann_v2_0_Inputs_S_AXIS
   generic map (
      RD_WIDTH => NbitIn,
      C_S_AXIS_TDATA_WIDTH   => C_Inputs_S_AXIS_TDATA_WIDTH
   )
   port map (
      fifo_rd => run_in,
      fifo_rdata => inputs,
      S_AXIS_ACLK   => inputs_s_axis_aclk,
      S_AXIS_ARESETN   => inputs_s_axis_aresetn,
      S_AXIS_TREADY   => inputs_s_axis_tready,
      S_AXIS_TDATA   => inputs_s_axis_tdata,
      S_AXIS_TSTRB   => inputs_s_axis_tstrb,
      S_AXIS_TLAST   => inputs_s_axis_tlast,
      S_AXIS_TVALID   => inputs_s_axis_tvalid
   );

-- Instantiation of Axi Bus Interface Outputs_M_AXIS
ann_v2_0_Outputs_M_AXIS_inst : ann_v2_0_Outputs_M_AXIS
   generic map (
      WR_WIDTH => NbitOut,
      NUMBER_OF_OUTPUT_WORDS => NumN_v(Nlayer-1),
      C_M_AXIS_TDATA_WIDTH   => C_Outputs_M_AXIS_TDATA_WIDTH
   )
   port map (
      fifo_wr => run_out,
      fifo_wdata => outputs,
      M_AXIS_ACLK   => outputs_m_axis_aclk,
      M_AXIS_ARESETN   => outputs_m_axis_aresetn,
      M_AXIS_TVALID   => outputs_m_axis_tvalid,
      M_AXIS_TDATA   => outputs_m_axis_tdata,
      M_AXIS_TSTRB   => outputs_m_axis_tstrb,
      M_AXIS_TLAST   => outputs_m_axis_tlast,
      M_AXIS_TREADY   => outputs_m_axis_tready
   );

-- Instantiation of Axi Bus Interface Wyb_S_AXI
ann_v2_0_Wyb_S_AXI_inst : ann_v2_0_Wyb_S_AXI
   generic map (
      ADDR_WIDTH => ANN_addr'length,
      DATA_WIDTH => NbitW,
      C_S_AXI_ID_WIDTH   => C_Wyb_S_AXI_ID_WIDTH,
      C_S_AXI_DATA_WIDTH   => C_Wyb_S_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH   => C_Wyb_S_AXI_ADDR_WIDTH,
      C_S_AXI_AWUSER_WIDTH   => C_Wyb_S_AXI_AWUSER_WIDTH,
      C_S_AXI_ARUSER_WIDTH   => C_Wyb_S_AXI_ARUSER_WIDTH,
      C_S_AXI_WUSER_WIDTH   => C_Wyb_S_AXI_WUSER_WIDTH,
      C_S_AXI_RUSER_WIDTH   => C_Wyb_S_AXI_RUSER_WIDTH,
      C_S_AXI_BUSER_WIDTH   => C_Wyb_S_AXI_BUSER_WIDTH
   )
   port map (
      m_en  => m_en,
      m_we  => m_we,
      wdata => wdata,
      addr  => ANN_addr,
      rdata => rdata,
      S_AXI_ACLK   => wyb_s_axi_aclk,
      S_AXI_ARESETN   => wyb_s_axi_aresetn,
      S_AXI_AWID   => wyb_s_axi_awid,
      S_AXI_AWADDR   => wyb_s_axi_awaddr,
      S_AXI_AWLEN   => wyb_s_axi_awlen,
      S_AXI_AWSIZE   => wyb_s_axi_awsize,
      S_AXI_AWBURST   => wyb_s_axi_awburst,
      S_AXI_AWLOCK   => wyb_s_axi_awlock,
      S_AXI_AWCACHE   => wyb_s_axi_awcache,
      S_AXI_AWPROT   => wyb_s_axi_awprot,
      S_AXI_AWQOS   => wyb_s_axi_awqos,
      S_AXI_AWREGION   => wyb_s_axi_awregion,
      S_AXI_AWUSER   => wyb_s_axi_awuser,
      S_AXI_AWVALID   => wyb_s_axi_awvalid,
      S_AXI_AWREADY   => wyb_s_axi_awready,
      S_AXI_WDATA   => wyb_s_axi_wdata,
      S_AXI_WSTRB   => wyb_s_axi_wstrb,
      S_AXI_WLAST   => wyb_s_axi_wlast,
      S_AXI_WUSER   => wyb_s_axi_wuser,
      S_AXI_WVALID   => wyb_s_axi_wvalid,
      S_AXI_WREADY   => wyb_s_axi_wready,
      S_AXI_BID   => wyb_s_axi_bid,
      S_AXI_BRESP   => wyb_s_axi_bresp,
      S_AXI_BUSER   => wyb_s_axi_buser,
      S_AXI_BVALID   => wyb_s_axi_bvalid,
      S_AXI_BREADY   => wyb_s_axi_bready,
      S_AXI_ARID   => wyb_s_axi_arid,
      S_AXI_ARADDR   => wyb_s_axi_araddr,
      S_AXI_ARLEN   => wyb_s_axi_arlen,
      S_AXI_ARSIZE   => wyb_s_axi_arsize,
      S_AXI_ARBURST   => wyb_s_axi_arburst,
      S_AXI_ARLOCK   => wyb_s_axi_arlock,
      S_AXI_ARCACHE   => wyb_s_axi_arcache,
      S_AXI_ARPROT   => wyb_s_axi_arprot,
      S_AXI_ARQOS   => wyb_s_axi_arqos,
      S_AXI_ARREGION   => wyb_s_axi_arregion,
      S_AXI_ARUSER   => wyb_s_axi_aruser,
      S_AXI_ARVALID   => wyb_s_axi_arvalid,
      S_AXI_ARREADY   => wyb_s_axi_arready,
      S_AXI_RID   => wyb_s_axi_rid,
      S_AXI_RDATA   => wyb_s_axi_rdata,
      S_AXI_RRESP   => wyb_s_axi_rresp,
      S_AXI_RLAST   => wyb_s_axi_rlast,
      S_AXI_RUSER   => wyb_s_axi_ruser,
      S_AXI_RVALID   => wyb_s_axi_rvalid,
      S_AXI_RREADY   => wyb_s_axi_rready
   );

   -- Add user logic here
ann_inst : entity work.ann
      generic map
      (
         Nlayer  => Nlayer,
         NumIn   => NumIn,
         NbitIn  => NbitIn,
         NbitW   => NbitW,
         NumN    => NumN_v,
         l_type  => l_type,
         f_type  => f_type,
         LSbit   => LSbit_v,
         NbitO   => NbitO_v,
         NbitOut => NbitOut
      )
      port map
      (
         -- Input ports:
         reset   => ann_areset,
         clk     => inputs_s_axis_aclk,
         run_in  => run_in, -- from control in ann_in_axi
         m_en    => m_en,
         m_we    => m_we, -- Beware with bit endian
         inputs  => inputs,
         wdata   => wdata,
         addr    => ANN_addr,
         
         -- Output ports:
         run_out => run_out, -- To control in ann_out_axi
         rdata   => rdata,
         --outs01  => outs01,
         --wr01    => IP2RFIFO2_WrReq,
         outputs => outputs
      );
   -- User logic ends

end arch_imp;
