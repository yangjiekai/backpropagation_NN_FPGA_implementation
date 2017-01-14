----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    15:27:42 06/20/2013
-- Design Name:    Configurable ANN
-- Module Name:    adder_tree - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: Recursive adder tree
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


entity adder_tree is
   generic
   (
      NumIn   : integer := 9;  -- Number of inputs
      Nbit    : integer := 12  -- Bit width of the input data
   );

   port
   (
      -- Input ports
      reset    : in  std_logic;
      clk      : in  std_logic;
      en       : in  std_logic; -- Enable
      inputs   : in  std_logic_vector((Nbit*NumIn)-1 downto 0); -- Input data

      -- Output ports
      en_out   : out std_logic; -- Output enable (output data validation)
      output   : out std_logic_vector(Nbit-1 downto 0) -- Output of the tree adder
   );
end adder_tree;

architecture Behavioral of adder_tree is

   constant NumIn2 : integer := NumIn/2; -- Number of imputs of the next adder tree layer

   signal next_en : std_logic := '0'; -- Next adder tree layer enable
   signal res : std_logic_vector((Nbit*((NumIn2)+(NumIn mod 2)))-1 downto 0); -- Partial results

   signal resL_reg : std_logic_vector((Nbit*NumIn2)-1 downto 0);
   signal resH_reg : std_logic_vector(Nbit-1 downto 0);
begin

-- Additions:
add_proc:
   process (clk) -- Synchronous to allow pipeline
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            resL_reg <= (others => '0');
         else
            if (en = '1') then
               -- Addition of inputs (2*i y 2*i+1), resulting in NumIn/2 outputs of this layer of the adder tree:
               for i in ((NumIn2)-1) downto 0 loop
                  resL_reg((Nbit*(i+1))-1 downto Nbit*i) <= std_logic_vector( signed(inputs((Nbit*((2*i)+1))-1 downto Nbit*2*i)) + signed(inputs((Nbit*((2*i)+2))-1 downto Nbit*((2*i)+1))) );
               end loop;
            end if;
         end if;
      end if;
   end process;

   res((Nbit*NumIn2)-1 downto 0) <= resL_reg;

-- Register the uneven input (if needed):
uneven_register:
   if (NumIn mod 2 = 1) generate
      process (clk)
      begin
         if (clk'event and clk = '1') then
            if (reset = '1') then
               resH_reg <= (others => '0');
            else
               if (en = '1') then
                  resH_reg <= inputs((Nbit*NumIn)-1 downto Nbit*(NumIn-1));
               end if;
            end if;
         end if;
      end process;
      res((Nbit*((NumIn2)+1))-1 downto Nbit*(NumIn2)) <= resH_reg;
   end generate;

   process (clk)
   begin
      if (clk'event and clk = '1') then
         if reset = '1' then
            next_en <= '0';
         else
            next_en <= en; -- Enable is delayed 1 cycle for the next layer of the adder tree
         end if;
      end if;
   end process;

recursion:
   if (NumIn > 2) generate

      sub_adder_tree: entity work.adder_tree
         generic map
         (
            NumIn => (NumIn2)+(NumIn mod 2),
            Nbit  => Nbit
         )
         port map
         (
            clk    => clk,
            reset  => reset,
            en     => next_en,
            inputs => res,
            en_out => en_out,
            output => output -- Solution is passed from the sub-adder trees to the top adder tree
         );
   end generate;

trivial_solution:
   if (NumIn = 2) generate
      en_out <= next_en;
      output <= res; -- Assign the final result to the adder tree output
   end generate;

end Behavioral;

