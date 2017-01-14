----------------------------------------------------------------------------------
-- Company: CEI - UPM
-- Engineer: David Aledo
--
-- Create Date:    11:31:38 05/14/2014
-- Design Name:    Configurable ANN
-- Module Name:    shiftreg_pl - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: Shift register with parallel load.
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


entity shiftreg_pl is
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
      inputs  : in  std_logic_vector((Nbit*Nreg)-1 downto 0); -- Input data (parallel)
      -- Output ports
      run_out : out std_logic; -- Output data validation, run_in for the next layer
      outputs : out std_logic_vector(Nbit-1 downto 0) -- Output data (serial)
   );
end shiftreg_pl;

architecture Behavioral of shiftreg_pl is

   signal count : integer range 0 to Nreg-1;
   signal en_r : std_logic;    --- Shift register enable
   type dreg_type is array (Nreg-1 downto 0) of std_logic_vector(Nbit-1 downto 0); -- Shift register type
   signal dreg : dreg_type;   ---- Shift register
   type reg_st_type is (idle, counting); -- Register state type
   signal reg_st : reg_st_type; -- Register state

begin

-- Shift register with parallel load:
   process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            dreg <= (others=> (others => '0'));
         else
            if en_r = '1' then -- Shift register enable
               if count = 0 then -- Parallel load
                  for i in 0 to Nreg-1 loop
                     dreg(i) <= inputs((Nbit*(i+1))-1 downto Nbit*i);
                  end loop;
               else  -- Other cycles, register is shifted
                  dreg(Nreg-1) <= (others => '-');
                  shift:
                  for i in 1 to Nreg-1 loop
                     dreg(i-1) <= dreg(i);
                  end loop;
               end if;
            end if;
         end if;
      end if;
   end process;
   outputs <= dreg(0);

-- Shift register control
   process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            count <= 0;
            reg_st <= idle;
            run_out <= '0';
         else
            run_out <= en_r;
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

