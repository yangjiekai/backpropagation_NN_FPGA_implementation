----------------------------------------------------------------------------------
-- Company:
-- Engineer: User
--
-- Create Date:
-- Design Name: Configurable ANN
-- Module Name: af_template - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: User activation function template.
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
use ieee.numeric_std.ALL;
use ieee.math_real.all;

-- Only entity name must be changed, please do not modify the template entity:
entity af_template is
   generic
   (
      Nbit : natural := 8
   );
   port
   (
      reset   : in  std_logic;
      clk     : in  std_logic;
      run_in  : in  std_logic; -- Start and input data validation
      inputs  : in  std_logic_vector(Nbit-1 downto 0); -- Input data
      run_out : out std_logic; -- Output data validation, run_in for the next layer
      outputs : out std_logic_vector(Nbit-1 downto 0) -- Output data
   );
end af_template;


architecture Behavioral of af_template is
   -- Add here user constants, internal signals, and other user definitions:

begin
   -- Add here user logic to describe the user activation function:

end Behavioral;
