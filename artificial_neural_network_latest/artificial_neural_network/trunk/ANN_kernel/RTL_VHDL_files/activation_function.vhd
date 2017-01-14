----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    16:16:02 05/14/2014
-- Design Name:    Configurable ANN
-- Module Name:    activation_function - Structural
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: Activation function selector. It instantiates the activation
--             funtion type selected with f_type parameter.
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


entity activation_function is
   generic
   (
      f_type : string := "linear"; -- Activation function type
      Nbit   : natural := 8        -- Bit width
   );
   port
   (
      reset   : in  std_logic;
      clk     : in  std_logic;
      run_in  : in  std_logic; -- Start and input data validation
      inputs  : in  std_logic_vector(Nbit-1 downto 0); -- Input data
      run_out : out std_logic; -- Output data validation, run_in for the next layer
      outputs : out std_logic_vector(Nbit-1 downto 0)  -- Output data
   );
end activation_function;

architecture Structural of activation_function is

begin

-- Linear activation function. It is a direct assignment:
linear_f:
   if (f_type = "linear") generate
      outputs <= inputs;
      run_out <= run_in;
   end generate;

-- Example 1: sigmoid activation function implemented as a Look-Up-Table (LUT):
Sigmoid_f:
   if (f_type = "siglut") generate
      siglut_inst: entity work.af_sigmoid
         generic map
         (
            Nbit => Nbit
         )
         port map
         (
            reset   => reset,
            clk     => clk,
            run_in  => run_in,
            inputs  => inputs,
            run_out => run_out,
            outputs => outputs
         );
   end generate;

-- Example 2: sigmoid activation function implemented as a LUT, with a second different set of parameters:
Sigmoid2_f:
   if (f_type = "siglu2") generate
      siglut_inst: entity work.af_sigmoid2
         generic map
         (
            Nbit => Nbit
         )
         port map
         (
            reset   => reset,
            clk     => clk,
            run_in  => run_in,
            inputs  => inputs,
            run_out => run_out,
            outputs => outputs
         );
   end generate;

-- Template to instance user activation function type ("userAF"):
--userAF_f:
   --if (f_type = "userAF") generate
      --yourAF_inst: entity work.--palace here user module name--
         --generic map
         --(
         --   Nbits => Nbits
         --)
         --port map
         --(
         --   reset => reset,
         --   clk   => clk,
         --   run_in  => run_in,
         --   inputs  => inputs,
         --   run_out => run_out,
         --   outputs => outputs
         --);
   --end generate;
-- User can instantiate as many types of activation function as needed, each one of them must be tagged as a 6 character string

end Structural;

