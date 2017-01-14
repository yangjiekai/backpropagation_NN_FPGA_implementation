----------------------------------------------------------------------------------
-- Company: CEI - UPM
-- Engineer: David Aledo
--
-- Create Date: 01.10.2015 15:15:28
-- Design Name: Configurable ANN
-- Module Name: ann - config_structural
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: generates the structure of an ANN with the given parameters.
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
use IEEE.NUMERIC_STD.ALL;

use work.layers_pkg.all;

entity ann is
   generic
   (
      Nlayer  : integer := 2;   ---- Number of layers
      NbitW   : natural := 16;  ---- Bit width of weights and biases
      NumIn   : natural := 64;  ---- Number of inputs to the network
      NbitIn  : natural := 8;   ---- Bit width of the inputs
      NumN    : int_vector;   ------ Number of neurons in each layer
      l_type  : string;   ---------- Layer type of each layer
      f_type  : string;   ---------- Activation function type of each layer
      LSbit   : int_vector;   ------ LSB of the output of each layer
      NbitO   : int_vector;   ------ Bit width of the outputs of each layer
      NbitOut : natural := 8   ----- Bit width of the network output
   );

   port
   (
      -- Input ports
      reset   : in  std_logic;
      clk     : in  std_logic;
      run_in  : in  std_logic; -- Start and input data validation
      m_en    : in  std_logic; -- Weight and bias memory enable (external interface)
      m_we    : in  std_logic_vector(((NbitW+7)/8)-1 downto 0); -- Weight and bias memory write enable (external interface)
      inputs  : in  std_logic_vector(NbitIn-1 downto 0); -- Input data
      wdata   : in  std_logic_vector(NbitW-1 downto 0);  -- Weight and bias memory write data
      addr    : in  std_logic_vector((calculate_addr_l(NumIn, NumN, Nlayer)+log2(Nlayer))-1 downto 0); -- Weight and bias memory address

      -- Output ports
      run_out : out std_logic; -- Output data validation
      rdata   : out std_logic_vector(NbitW-1 downto 0);  -- Weight and bias memory read data
      outputs : out std_logic_vector(NbitOut-1 downto 0) -- Output data
   );
end ann;

architecture config_structural of ann is

   -- Arrays of configuration constants, generated from string generics:
   constant ltype_v : ltype_vector(Nlayer-1 downto 0) := assign_ltype(l_type,Nlayer);
   constant ftype_v : ftype_vector(Nlayer-1 downto 0) := assign_ftype(f_type,Nlayer);
   constant lra_l  : int_vector(Nlayer-1 downto 0) := assign_addrl(NumIn,NumN,Nlayer); -- Layer RAM address length of each layer
   constant NumIn_v : int_vector(Nlayer-1 downto 0) := NumN(Nlayer-2 downto 0) & NumIn;
   constant wra_l   : int_vector(Nlayer-1 downto 0) := log2(NumIn_v, Nlayer); -- Weight RAM address length of each layer
   constant bra_l   : int_vector(Nlayer-1 downto 0) := log2(NumN, Nlayer); -- Bias ram address length of each layer

   -- Internal signals:
   signal lm_en  : std_logic_vector(Nlayer-1 downto 0); -- Weight and bias memory enable of each layer
   type lrd_type is array (Nlayer-1 downto 0) of std_logic_vector(NbitW-1 downto 0);
   signal lrdata : lrd_type; -- Weight and bias memory read data of each layer

   type lodata_t is array (Nlayer-1 downto 0) of std_logic_vector(calculate_max_mul(NbitO,NumN)-1 downto 0); -- Parallel or serial data
   type ladata_t is array (Nlayer-1 downto 0) of std_logic_vector(calculate_max(NbitO)-1 downto 0); -- Always serial data
   signal runO : std_logic_vector(Nlayer-1 downto 0); -- Output data validation of each layer (before activation function)
   signal runI : std_logic_vector(Nlayer-1 downto 0); -- Input data validation of each layer
   signal runA : std_logic_vector(Nlayer-1 downto 0); -- Auxiliar serial data validation of each layer
   signal lodata : lodata_t; -- Output data of each layer (before activation function)
   signal lidata : lodata_t; -- Input data of each layer
   signal ladata : ladata_t; -- Auxiliar serial data of each layer

begin

-- Weight and bias memory layer selection (combinational mux):
   process (addr(addr'length-1 downto addr'length-log2(Nlayer)), m_en, lrdata)
   begin
      for i in 0 to Nlayer-1 loop
         if to_integer(unsigned(addr(addr'length-1 downto addr'length-log2(Nlayer)))) = i then
            lm_en(i) <= m_en;
            rdata <= lrdata(i);
         else
            lm_en(i) <= '0';
         end if;
      end loop;
      -- Note: Attention with addresses greater than Nlayer when it is not a power of two
   end process;

-- ATTENTION: without the following if generate, the first layer must have serial input ('S')
parallelize_inputs:
if ltype_v(0)(1) = 'P' generate
   -- TODO: instantiate shift register with parallel output.
   -- synthesis translate_off
   assert ltype_v(0)(1) /= 'P'
      report "Current version does not accept parallel inputs."
      severity failure;
   -- synthesis translate_on
   -- TODO: delete above lines when instantiate shift register with parallel output.
end generate;

first_layer_SP:
if ltype_v(0) = "SP" generate

first_layerSP_top_inst: entity work.layerSP_top
   generic map
   (
      NumN    => NumN(0),   -- Number of neurons in the first layer
      NumIn   => NumIn,   ---- Number of inputs of the first layer
      NbitIn  => NbitIn,   --- Bit width of the input data
      NbitW   => NbitW,   ---- Bit width of weights and biases
      NbitOut => NbitO(0),  -- Bit width of the first layer output
      lra_l   => lra_l(0),  -- Layer RAM address length of the first layer
      wra_l   => wra_l(0),  -- Weight RAM address length of the first layer
      bra_l   => bra_l(0),  -- Bias RAM address length of the first layer
      LSbit   => LSbit(0)   -- Less significant bit of the first layer outputs
   )
   port map
   (
      -- Input ports
      reset   => reset,
      clk     => clk,
      run_in  => run_in,   --- Input data validation of the first layer
      m_en    => lm_en(0),  -- Weight and bias memory enable of the first layer
      b_sel   => addr((addr'length-log2(Nlayer))-1), -- Bias select. Selects between layer or bias memories
      m_we    => m_we,   ----- Weight and bias memory write enable
      inputs  => inputs,   --- Inputs of the first layer (serial data)
      wdata   => wdata,   ---- Weight and bias memory write data
      addr    => addr(lra_l(0)-1 downto 0), -- Weight and bias memory address of the first layer

      -- Output ports
      run_out => runO(0),   -- Output data validation of the first layer
      rdata   => lrdata(0), -- Weight and bias memory read data of the first layer
      outputs => lodata(0)((NumN(0)*NbitO(0))-1 downto 0) -- Outputs of the first layer (parallel data)
   );
end generate;


layers_insts:
for i in 1 to Nlayer-1 generate

   -- If the previous layer (i-1) has parallel outputs and actual layer (i) has serial inputs, a serializer
   -- is inserted before the activation function (i-1). So, parallel activations functions are avoided.
serializer:
   if (ltype_v(i-1)(2) = 'P') and (ltype_v(i)(1) = 'S') generate

      -- Instantiate shift-register with parallel load:
shiftreg_parallel_load: entity work.shiftreg_pl
      generic map
      (
         Nreg => NumN(i-1),   --- Number of registers in the shift-register corresponds with the number of neurons in the previous layer (i-1)
         Nbit => NbitO(i-1)   --- Bit width of the registers corresponds with the bit width of the outputs of the previous layer (i-1)
      )
      port map
      (
         reset   => reset,
         clk     => clk,
         run_in  => runO(i-1), -- Input data validation of the shift-register comes from the output data validation of the previous layer (i-1)
         inputs  => lodata(i-1)((NumN(i-1)*NbitO(i-1))-1 downto 0), -- Parallel input data to the shift-register come from the previous layer (i-1)
         run_out => runA(i-1), -- Output data validation goes to the activation function of the previous layer (i-1)
         outputs => ladata(i-1)(NbitO(i-1)-1 downto 0) -- Output serial data go to the activation function of the previous layer (i-1)
      );

      -- Instantiate single activation function of the previous layer (i-1):
activation_function_inst: entity work.activation_function
      generic map
      (
         f_type => ftype_v(i-1), -- Activation function type of the previous layer (i-1)
         Nbit   => NbitO(i-1)   --- Bit width of the outputs of the previous layer (i-1)
      )
      port map
      (
         reset   => reset,
         clk     => clk,
         run_in  => runA(i-1),   -- Input data validation comes from the shift-register
         inputs  => ladata(i-1)(NbitO(i-1)-1 downto 0), -- Serial input data come from the shift-register
         run_out => runI(i-1),   -- Output data validation goes to the input data validation of this layer
         outputs => lidata(i-1)(NbitO(i-1)-1 downto 0) -- Serial output data go to the inputs of this layer
      );

   end generate; -- serializer

   -- If the previous layer (i-1) has serial outputs and actual layer (i) has serial inputs,
   -- a single activation function is instantiated:
single_activation_function:
   if (ltype_v(i-1)(2) = 'S') and (ltype_v(i)(1) = 'S') generate

      -- Instantiate single activation function of the previous layer (i-1):
activation_function_inst: entity work.activation_function
      generic map
      (
         f_type => ftype_v(i-1), -- Activation function type of the previous layer (i-1)
         Nbit   => NbitO(i-1)   --- Bit width of the outputs of the previous layer (i-1)
      )
      port map
      (
         reset   => reset,
         clk     => clk,
         run_in  => runO(i-1),   -- Input data validation comes from the previous layer (i-1)
         inputs  => lodata(i-1)(NbitO(i-1)-1 downto 0), -- Serial input data come from the previous layer (i-1)
         run_out => runI(i-1),   -- Output data validation goes to the input data validation of this layer
         outputs => lidata(i-1)(NbitO(i-1)-1 downto 0) -- Serial output data go to the inputs of this layer
      );

   end generate; -- single_activation_function

   -- If the previous layer (i-1) has parallel outputs and actual layer (i) has parallel inputs,
   -- multiple parallel activation functions are instantiated:
multiple_activation_functions:
   if (ltype_v(i-1)(2) = 'P') and (ltype_v(i)(1) = 'P') generate

      -- First of the parallel activation functions. This is the one which generates the output data validation
act_function_inst_0: entity work.activation_function
      generic map
      (
         f_type => ftype_v(i-1), -- Activation function type of the previous layer (i-1)
         Nbit   => NbitO(i-1)   --- Bit width of the outputs of the previous layer (i-1)
      )
      port map
      (
         reset   => reset,
         clk     => clk,
         run_in  => runO(i-1),   -- Input data validation comes from the previous layer (i-1)
         inputs  => lodata(i-1)(NbitO(i-1)-1 downto 0), -- First of the parallel input data wich comes from the previous layer (i-1)
         run_out => runI(i-1),   -- Output data validation goes to the input data validation of this layer
         outputs => lidata(i-1)(NbitO(i-1)-1 downto 0)  -- First of the parallel inputs of this layer
      );

      -- Rest of the parallel activation functions of the previous layer (i-1)
multiple_activation_function_insts:
      for j in 1 to NumN(i-1)-1 generate
activation_function_inst: entity work.activation_function
         generic map
         (
            f_type => ftype_v(i-1), -- Activation function type of the previous layer (i-1)
            Nbit   => NbitO(i-1)   --- Bit width of the outputs of the previous layer (i-1)
         )
         port map
         (
            reset   => reset,
            clk     => clk,
            run_in  => runO(i-1),   -- Input data validation comes from the previous layer (i-1)
            inputs  => lodata(i-1)((NbitO(i-1)*(j+1))-1 downto NbitO(i-1)*j), -- Rest of the parallel input data which come from the previous layer (i-1)
            run_out => open,   ------- As only one output data validation is needed, the rest ones are left unconnected
            outputs => lidata(i-1)((NbitO(i-1)*(j+1))-1 downto NbitO(i-1)*j)  -- Rest of the parallel inputs of this layer
         );
      end generate;

   end generate; -- multiple_activation_functions

   -- If the previous layer (i-1) has serial outputs and actual layer (i) has parallel inputs, a parallelizer
   -- is insested after the activation function (i-1):
parallelizer:
   if (ltype_v(i-1)(2) = 'S') and (ltype_v(i)(1) = 'P') generate

      -- Instantiate single activation function of the previous layer (i-1):
activation_function_inst: entity work.activation_function
      generic map
      (
         f_type => ftype_v(i-1),
         Nbit   => NbitO(i-1)
      )
      port map
      (
         reset   => reset,
         clk     => clk,
         run_in  => runO(i-1),
         inputs  => lodata(i-1)(NbitO(i-1)-1 downto 0),
         run_out => runA(i-1),
         outputs => ladata(i-1)(NbitO(i-1)-1 downto 0)
      );

      -- Instantiate shift-register with parallel unload:
shiftreg_parallel_unload: entity work.shiftreg_pu
      generic map
      (
         Nreg => NumN(i-1),   --- Number of registers in the shift-register corresponds with the number of neurons in the previous layer (i-1)
         Nbit => NbitO(i-1)   --- Bit width of the registers corresponds with the bit width of the outputs of the previous layer (i-1)
      )
      port map
      (
         reset   => reset,
         clk     => clk,
         run_in  => runA(i-1), -- Input data validation comes from the activation function of the previous layer (i-1)
         inputs  => ladata(i-1)(NbitO(i-1)-1 downto 0), -- Serial input data
         run_out => runO(i-1), -- Output data validation goes to the input data validation of this layer
         outputs => lodata(i-1)((NumN(i-1)*NbitO(i-1))-1 downto 0) -- Parallel output data
      );

   end generate; -- parallelizer

   -- Instance the layer (i), cases SP, PS or PP:

   -- Serial-input parallel-output layer:
SP_case:
   if ltype_v(i) = "SP" generate
layerSP_top_inst: entity work.layerSP_top
      generic map
      (
         NumN    => NumN(i),   --- Number of neurons in layer (i)
         NumIn   => NumN(i-1),  -- Number of inputs, is the number of neurons in previous layer (i-1)
         NbitIn  => NbitO(i-1), -- Bit width of the input data, is the bit width of output data of layer (i-1)
         NbitW   => NbitW,   ----- Bit width of weights and biases
         NbitOut => NbitO(i),   -- Bit width of layer (i) output
         lra_l   => lra_l(i),   -- Layer RAM address length of layer (i)
         wra_l   => wra_l(i),   -- Weight RAM address length of layer (i)
         bra_l   => bra_l(i),   -- Bias RAM address length of layer (i)
         LSbit   => LSbit(i)   --- Less significant bit of layer (i) outputs
      )
      port map
      (
         -- Input ports
         reset   => reset,
         clk     => clk,
         run_in  => runI(i-1),  -- Input data validation of this layer
         m_en    => lm_en(i),   -- Weight and bias memory enable of this layer
         b_sel   => addr((addr'length-log2(Nlayer))-1), -- Bias select. Selects between layer or bias memories
         m_we    => m_we,   ------ Weight and bias memory write enable
         inputs  => lidata(i-1)(NbitO(i-1)-1 downto 0), -- Inputs of this layer (serial data)
         wdata   => wdata,   ----- Weight and bias memory write data
         addr    => addr(lra_l(i)-1 downto 0), -- Weight and bias memory address of this layer

         -- Output ports
         run_out => runO(i),   -- Output data validation of this layer
         rdata   => lrdata(i), -- Weight and bias memory read data of this layer
         outputs => lodata(i)((NumN(i)*NbitO(i))-1 downto 0) -- Outputs of this layer (parallel data)
      );
   end generate;

   -- Parallel-input serial-output layer:
PS_case:
   if ltype_v(i) = "PS" generate
layerPS_top_inst: entity work.layerPS_top
      generic map
      (
         NumN    => NumN(i),   --- Number of neurons in layer (i)
         NumIn   => NumN(i-1),  -- Number of inputs, is the number of neurons in previous layer (i-1)
         NbitIn  => NbitO(i-1), -- Bit width of the input data, is the bit width of output data of layer (i-1)
         NbitW   => NbitW,   ----- Bit width of weights and biases
         NbitOut => NbitO(i),   -- Bit width of layer (i) output
         lra_l   => lra_l(i),   -- Layer RAM address length of layer (i)
         wra_l   => wra_l(i),   -- Weight RAM address length of layer (i)
         bra_l   => bra_l(i),   -- Bias ram address length of layer (i)
         LSbit   => LSbit(i)   --- Less significant bit of layer (i) outputs
      )
      port map
      (
         -- Input ports
         reset   => reset,
         clk     => clk,
         run_in  => runI(i-1),  -- Input data validation of this layer
         m_en    => lm_en(i),   -- Weight and bias memory enable of this layer
         b_sel   => addr((addr'length-log2(Nlayer))-1), -- Bias select. Selects between layer or bias memories
         m_we    => m_we,   ------ Weight and bias memory write enable
         inputs  => lidata(i-1)((NumN(i-1)*NbitO(i-1))-1 downto 0), -- Inputs of this layer (parallel data)
         wdata   => wdata,   ----- Weight and bias memory write data
         addr    => addr(lra_l(i)-1 downto 0), -- Weight and bias memory address of this layer

         -- Output ports
         run_out => runO(i),   -- Output data validation of this layer
         rdata   => lrdata(i), -- Weight and bias memory read data of this layer
         outputs => lodata(i)(NbitO(i)-1 downto 0) -- Outputs of this layer (serial data)
      );
   end generate;

   -- Parallel-input parallel-output layer:
PP_case:
   if ltype_v(i) = "PP" generate
      -- TODO: instance a full parallel layer. At current version this layer type has not been developed.
      -- synthesis translate_off
      assert l_type(i) /= "PP"
         report "Current version does not accept parallel-input parallel-output (PP) layer type."
         severity failure;
      -- synthesis translate_on
      -- TODO: delete above lines when instantiate the parallel-input parallel-output layer.
   end generate;

end generate; -- layers_insts

-- If the last layer (Nlayer-1) has parallel outputs, a serializer is inserted before the activation function:
last_serializer:
if (ltype_v(Nlayer-1)(2) = 'P') generate

   -- Instantiate shift-register with parallel load:
last_shiftreg_parallel_load: entity work.shiftreg_pl
   generic map
   (
      Nreg => NumN(Nlayer-1),   --- Number of registers corresponds with the number of neurons in the last layer (Nlayer-1)
      Nbit => NbitO(Nlayer-1)   --- Bit width of the registers corresponds with the bit width of the outputs of the last layer (Nlayer-1)
   )
   port map
   (
      reset   => reset,
      clk     => clk,
      run_in  => runO(Nlayer-1), -- Input data validation comes from the output data validation of the last layer (Nlayer-1)
      inputs  => lodata(Nlayer-1)((NumN(Nlayer-1)*NbitO(Nlayer-1))-1 downto 0), -- Parallel input data come from the last layer
      run_out => runA(Nlayer-1), -- Output data validation goes to the last activation function (Nlayer-1)
      outputs => ladata(Nlayer-1)(NbitO(Nlayer-1)-1 downto 0) -- Serial output data go to the last activation function
   );

last_activation_function_inst: entity work.activation_function
      generic map
      (
         f_type => ftype_v(Nlayer-1), -- Activation function type of the last layer (Nlayer-1)
         Nbit   => NbitO(Nlayer-1)   --- Bit width of the outputs of the last layer (Nlayer-1)
      )
      port map
      (
         reset   => reset,
         clk     => clk,
         run_in  => runA(Nlayer-1),   -- Input data validation comes from the shift-register output validation
         inputs  => ladata(Nlayer-1)(NbitO(Nlayer-1)-1 downto 0), -- Serial input data come from the shift-register
         run_out => run_out,   --------- Output data validation of the network
         outputs => outputs   ---------- Outputs of the network (serial data)
      );

end generate; -- last_serializer

-- If the las layer has serial outputs:
last_simple_activation_function:
if (ltype_v(Nlayer-1)(2) = 'S') generate
last_activation_function_inst: entity work.activation_function
      generic map
      (
         f_type => ftype_v(Nlayer-1), -- Activation function type of the last layer (Nlayer-1)
         Nbit   => NbitO(Nlayer-1)   --- Bit width of the outputs of the last layer (Nlayer-1)
      )
      port map
      (
         reset   => reset,
         clk     => clk,
         run_in  => runO(Nlayer-1),   -- Input data validation comes from the last layer (Nlayer-1) output validation
         inputs  => lodata(Nlayer-1)(NbitO(Nlayer-1)-1 downto 0), -- Inputs come from the outputs of the last layer (serial data)
         run_out => run_out,   --------- Output data validation of the network
         outputs => outputs   ---------- Outputs of the network (serial data)
      );
end generate;

end config_structural;
