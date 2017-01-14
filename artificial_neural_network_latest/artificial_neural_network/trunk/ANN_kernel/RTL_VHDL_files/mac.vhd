----------------------------------------------------------------------------------
-- Company: CEI
-- Engineer: David Aledo
--
-- Create Date:
-- Design Name:    Configurable ANN
-- Module Name:    mac - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: Multiplier and accumulator (MAC).
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
use ieee.numeric_std.all;


entity mac is
   generic
   (
      dirload : boolean := FALSE; -- Direct load. Load accumulator with port C value (TRUE) or A*B + C (FALSE)
      NbOvrf  : natural := 3;   ---- Extra bits in acc to avoid overflow
      NbitIn  : natural := 16;   --- Bit width of the input data
      NbitC   : natural := 18   ---- Bit width of weight and bias
   );
   port
   (
      CLK  : in  std_logic;
      RST  : in  std_logic;
      A    : in  STD_LOGIC_VECTOR (NbitIn-1 DOWNTO 0); -- Input data
      B    : in  STD_LOGIC_VECTOR (NbitC-1 DOWNTO 0);  -- Weights
      C    : in  std_logic_vector (NbitC-1 downto 0);  -- Bias
      P    : out std_logic_vector (NbitIn+NbitC+NbOvrf DOWNTO 0); -- Output data
      CE1  : in  std_logic;  -- Multiplier eneble
      CE2  : in  std_logic;  -- Accumulator enable
      LOAD : in  std_logic   -- Load signal. Resets the accumulator with value determined by dirload parameter
      );
end mac;

architecture Behavioral of mac is

   signal acc  : signed (NbitIn+NbitC+NbOvrf DOWNTO 0) := (others => '0'); -- Accumulator register
   signal Mreg : signed (NbitIn+NbitC-1 DOWNTO 0) := (others => '0');  -- Multiplier output register

begin

   process (CLK)
   begin
      if CLK'event and CLK = '1' then
         if RST = '1' then
            acc  <= (others => '0');
            Mreg <= (others => '0');
         else
            if CE1 = '1' then
               Mreg <= signed(A)*signed(B);
            end if;
            if CE2 = '1' then
               if LOAD = '1' then
                  if dirload then
                     -- Load acc with port C value (bias):
                     acc <= resize(signed(C),NbitIn+NbitC+NbOvrf+1); -- Sign extension
                  else
                     -- Load acc with A*B + C (bias):
                     acc <= resize(signed(C),NbitIn+NbitC+NbOvrf+1) + Mreg;
                  end if;
               else
                  acc <= acc + Mreg;
               end if;
            end if;
         end if;
      end if;
   end process;

   P <= std_logic_vector(acc);

end Behavioral;

