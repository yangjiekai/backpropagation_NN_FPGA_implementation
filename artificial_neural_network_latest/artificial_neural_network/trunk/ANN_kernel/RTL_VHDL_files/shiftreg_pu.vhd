----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    18:03:58 05/14/2014
-- Design Name:    Configurable ANN
-- Module Name:    shiftreg_pu - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: Shift register with parallel unload.
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


entity shiftreg_pu is
   generic
   (
      Nreg : natural := 64;  ---- Number of elements
      Nbit : natural := 8    ---- Bit width
   );

   port
   (
      -- Input ports
      reset   : in  std_logic;
      clk     : in  std_logic;
      run_in  : in  std_logic; -- Start and input data validation
      inputs  : in  std_logic_vector(Nbit-1 downto 0); -- Input data (serial)
      -- Output ports
      run_out : out std_logic; -- Output data validation, run_in for the next layer
      outputs : out std_logic_vector((Nbit*Nreg)-1 downto 0) -- Output data (parallel)
   );
end shiftreg_pu;

architecture Behavioral of shiftreg_pu is

   signal count : integer range 0 to Nreg-1;
   signal en_r : std_logic;    --- Shift register enable
   signal unload : std_logic;   -- Unload signal to unload the shift register onto the output register
   type dreg_type is array (Nreg-1 downto 0) of std_logic_vector(Nbit-1 downto 0); -- Shift register type
   signal dreg : dreg_type;   ---- Shift register
   type reg_st_type is (idle, counting); -- Register state type
   signal reg_st : reg_st_type; -- Register state

begin

-- Shift register with parallel unload:
   process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            dreg <= (others=> (others => '0'));
         else
            if en_r = '1' then -- Shift register enable
               dreg(Nreg-1) <= inputs; -- Every cycle a new input data is loaded
               if count /= 0 then -- When count = 0, shift register is unloaded; other cycles, register is shifted
                  shift:
                  for i in 1 to Nreg-1 loop
                     dreg(i-1) <= dreg(i);
                  end loop;
               end if;
            end if;
         end if;
      end if;
   end process;

   process (clk) -- Output register to mantain constant output the data for pipeline
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            outputs <= (others=> '0');
         else
            if unload = '1' then -- Parallel unload
               for i in 0 to Nreg-1 loop
                  outputs((Nbit*(i+1))-1 downto Nbit*i) <= dreg(i);
               end loop;
            end if;
         end if;
      end if;
   end process;

-- Shift register control
   process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            count <= 0;
            reg_st <= idle;
            run_out <= '0';
            unload <= '0';
         else
            run_out <= unload;
            case reg_st is
               when idle =>
                  if run_in = '1' then
                     reg_st <= counting;
                  else
                     reg_st <= idle;
                  end if;
               when counting =>
                  if count = (Nreg-1) then
                     reg_st <= idle;
                     count <= 0;
                     unload <= '1';
                  else
                     reg_st <= counting;
                     count <= count +1;
                  end if;
            end case;
         end if;
      end if;
   end process;
   process (reg_st)
   begin
      if reg_st = counting then
         en_r <= '1';
      else
         en_r <= '0';
      end if;
   end process;

end Behavioral;

