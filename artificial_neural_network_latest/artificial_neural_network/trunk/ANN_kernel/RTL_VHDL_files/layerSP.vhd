----------------------------------------------------------------------------------
-- Company: CEI
-- Engineer: David Aledo
--
-- Create Date:    11:24:24 05/28/2013
-- Design Name:    Configurable ANN
-- Module Name:    layerSP - arq
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: basic and parametrizable neuron layer for hardware artificial
--             neural networks. Serial input and parallel output.
--             Implemented by MAC.
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

-- NOTE: To optimize MAC, inputs should be registered, and should be checked that this register is implemented as DSP input register

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.layers_pkg.all;


entity layerSP is

   generic
   (
      NumN    : natural := 8;  -- Number of neurons of the layer
      NumIn   : natural := 64; -- Number of inputs of each neuron (data account before restart Acc)
      NbitIn  : natural := 8;  -- Bit width of the input data
      NbitW   : natural := 8;  -- Bit width of weights and biases
      NbitOut : natural := 12; -- Bit width of the output data
      LSbit   : natural := 4   -- Less significant bit of the outputs
   );

   port
   (
      -- Input ports
      reset    : in  std_logic;
      clk      : in  std_logic;
      en       : in  std_logic; -- First step enable (multiplication of MAC)
      en2      : in  std_logic; -- Second stage enable (accumulation of MAC)
      en_r     : in  std_logic; -- Shift register enable
      a0       : in  std_logic; -- Signal to load accumulators with the multiplication result
      inputs   : in  std_logic_vector(NbitIn-1 downto 0);       -- Input data (serial)
      Wyb      : in  std_logic_vector((NbitW*NumN)-1 downto 0); -- Weight vectors
      bias     : in  std_logic_vector((NbitW*NumN)-1 downto 0); -- Bias vector

      -- Output ports
      outputs  : out std_logic_vector((NbitOut*NumN)-1 downto 0) -- Output data (parallel)
   );
end layerSP;



architecture arq of layerSP is

   constant NbOvrf : natural := log2(NumIn); -- Extra bits in acc to avoid overflow
   constant sat_max : signed(NbitIn+NbitW+NbOvrf downto 0) := (NbitIn+NbitW+NbOvrf downto LSbit+NbitOut-1 => '0') & (LSbit+NbitOut-2 downto 0 => '1'); -- E.g. "0001111"
   constant sat_min : signed(NbitIn+NbitW+NbOvrf downto 0) := (NbitIn+NbitW+NbOvrf downto LSbit+NbitOut-1 => '1') & (LSbit+NbitOut-2 downto 0 => '0'); -- E.g. "1110000"

   type v_res is array(NumN-1 downto 0) of std_logic_vector(NbitIn+NbitW+NbOvrf downto 0); -- Array type for MAC results
   type v_reg is array(NumN-1 downto 0) of std_logic_vector(NbitOut-1 downto 0);           -- Array type for shift register

   signal res   : v_res; -- MAC results
   signal reg   : v_reg := (others => (others => '0')); -- Output register

begin

macs: -- Instances as MAC as NumN
   for i in (NumN-1) downto 0 generate
      mac_i: entity work.mac
         generic map
         (
            dirload => FALSE,
            NbOvrf  => NbOvrf,
            NbitIn  => NbitIn,
            NbitC   => NbitW
         )
         port map
         (
            CLK => clk,
            RST => reset,
            A   => inputs,
            B   => Wyb((NbitW*(i+1))-1 downto NbitW*i),
            C   => bias((NbitW*(i+1))-1 downto NbitW*i),
            P   => res(i),
            CE1 => en,
            CE2 => en2,
            LOAD => a0
         );
   end generate;

   process(clk)
   begin
      if rising_edge(clk) then
         if reset = '1' then -- Synchronous reset, active high
            reg <= (others => (others => '0'));
         else

            if en_r = '1' then -- Output register enable (clipping)

               for i in 0 to NumN-1 loop -- As many results as NumN are loaded in parallel

                  if signed(res(i)) > sat_max then
                     -- Saturating result to the maximum value:
                     reg(i) <= '0' & (NbitOut-2 downto 0 => '1');
                  elsif signed(res(i)) < sat_min then
                     -- Saturating result to the minimum value:
                     reg(i) <= '1' & (NbitOut-2 downto 0 => '0');
                  else
                     -- Configured window of result bits are assigned to the output:
                     reg(i) <= res(i)(LSbit+NbitOut-1 downto LSbit);
                  end if;

               end loop;

            end if;
         end if;

      end if;
   end process;

-- Assigns output registers to output data port:
   process (reg)
   begin
      for i in 0 to NumN-1 loop
         outputs((NbitOut*(i+1))-1 downto NbitOut*i) <= reg(i);
      end loop;
   end process;

end arq;
