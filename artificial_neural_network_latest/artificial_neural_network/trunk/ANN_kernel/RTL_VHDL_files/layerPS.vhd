----------------------------------------------------------------------------------
-- Company: CEI
-- Engineer: David Aledo
--
-- Create Date:    11:24:24 05/28/2013
-- Design Name:    Configurable ANN
-- Module Name:    layerPS - arq
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: basic and parametrizable neuron layer for hardware artificial
--             neural networks. Paralel input and serial output.
--             It implemnts one neuron reused to calculate all.
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Deprecated XPS library: -- Needed functions have been implemented in layers_pkg
--library proc_common_v3_00_a;
--use proc_common_v3_00_a.proc_common_pkg.all;

use work.layers_pkg.all;


entity layerPS is

   generic
   (
      NumN    : natural := 64; -- Number of neurons of the layer
      NumIn   : natural := 8;  -- Number of inputs of each neuron
      NbitIn  : natural := 12; -- Bit width of the input data
      NbitW   : natural := 8;  -- Bit width of weights and biases
      NbitOut : natural := 8;  -- Bit width of the output data
      LSbit   : natural := 4   -- Less significant bit of the outputs
   );

   port
   (
      -- Input ports
      reset    : in  std_logic;
      clk      : in  std_logic;
      en       : in  std_logic; -- First step enable
      en2      : in  std_logic; -- Second stage enable
      en_r     : in  std_logic; -- Output register enable
      inputs   : in  std_logic_vector((NbitIn*NumIn)-1 downto 0); -- Input data (parallel)
      Wyb      : in  std_logic_vector((NbitW*NumIn)-1 downto 0);  -- Weight vectors
      bias     : in  std_logic_vector(NbitW-1 downto 0);   --------- Bias

      -- Output ports
      en_out   : out std_logic; -- Output data validation
      outputs  : out std_logic_vector(NbitOut-1 downto 0) -- Output data (serial)
   );
end layerPS;



architecture arq of layerPS is

   constant NbOvrf : natural := log2(NumIn); -- Extra bits avoid overflow in adders
   constant sat_max : signed(NbitIn+NbitW+NbOvrf downto 0) := (NbitIn+NbitW+NbOvrf downto LSbit+NbitOut-1 => '0') & (LSbit+NbitOut-2 downto 0 => '1'); -- E.g. "0001111"
   constant sat_min : signed(NbitIn+NbitW+NbOvrf downto 0) := (NbitIn+NbitW+NbOvrf downto LSbit+NbitOut-1 => '1') & (LSbit+NbitOut-2 downto 0 => '0'); -- E.g. "1110000"

   type v_res is array(NumIn-1 downto 0) of signed((NbitIn+NbitW)-1 downto 0); -- Array type for results from multipliers

   signal res  : v_res := (others => (others => '0')); -- Results from multipliers
   signal sum  : std_logic_vector(NbitIn+NbitW+NbOvrf downto 0) := (others => '0');   -- Addition result
   signal reg  : std_logic_vector(NbitOut-1 downto 0) := (others => '0');    ----------- Output register
   signal sum_aux : std_logic_vector(((NbitIn+NbitW+NbOvrf+1)*(NumIn+1))-1 downto 0); -- Pipeline registers for adders

begin

muls: -- Instances as multipliers as NumIn
   for i in (NumIn-1) downto 0 generate
      process (clk) -- Multiplier
      begin
         if (clk'event and clk = '1') then
            if (reset = '1') then
               res(i) <= (others => '0');
            else
               if (en = '1') then
                  -- Multiplies every input with its weight:
                  res(i) <= signed(inputs((NbitIn*(i+1))-1 downto NbitIn*i)) * signed(Wyb((NbitW*(i+1))-1 downto NbitW*i));
               end if;
            end if;
         end if;
      end process;
   end generate;

asign_adder_tree_inputs:
   for i in NumIn-1 downto 0 generate
      sum_aux(((NbitIn+NbitW+NbOvrf+1)*(i+1))-1 downto (NbitIn+NbitW+NbOvrf+1)*i) <= std_logic_vector(resize(res(i),NbitIn+NbitW+NbOvrf+1));
   end generate;
   sum_aux(((NbitIn+NbitW+NbOvrf+1)*(NumIn+1))-1 downto (NbitIn+NbitW+NbOvrf+1)*NumIn) <= std_logic_vector(resize(signed(bias),NbitIn+NbitW+NbOvrf+1)); -- Bias is added placed in the last position

recursive_adder_tree: entity work.adder_tree
         generic map
         (
            NumIn => NumIn+1, -- +bias
            Nbit  => NbitIn+NbitW+NbOvrf+1
         )
         port map
         (
            clk    => clk,
            reset  => reset,
            en     => en2,
            inputs => sum_aux,
            en_out => en_out,
            output => sum
         );


   process(clk)
   begin
      if(rising_edge(clk)) then
         if(reset = '1') then -- Synchronous reset, active high
            reg <= (others => '0');
         else

            if en_r = '1' then -- Output register enable (clipping)

               if signed(sum) > sat_max then
                  -- Saturating result to the maximum value:
                  reg <= '0' & (NbitOut-2 downto 0 => '1');
               elsif signed(sum) < sat_min then
                  -- Saturating result to the minimum value:
                  reg <= '1' & (NbitOut-2 downto 0 => '0');
               else
                  -- Configured window of result bits are assigned to the output:
                  reg <= sum(LSbit+NbitOut-1 downto LSbit);
               end if;

            end if;
         end if;

      end if;
   end process;

-- Assigns output register to output data port:
   outputs <= reg;

end arq;
