----------------------------------------------------------------------------------
-- Company: CEI
-- Engineer: Enrique Herrero
--
-- Create Date:
-- Design Name: Configurable ANN
-- Module Name: af_sigmoid - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: Sigmoid activation function implemented as a Look-Up-Table (LUT).
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1 - David Aledo
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.math_real.all;


entity af_sigmoid is
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
end af_sigmoid;


architecture Behavioral of af_sigmoid is

   -- Definition of internal modules, constants, signals, etc...

   -- Sigmoid parameters:
   constant f0 : real := 2.0; -- Slope at the origin
   constant fr : real := 2.0; -- fr = fmax - fmin

   signal dataIn: integer range (2**Nbit-1) downto 0; -- To convert std_logic_vector input to integer index for the LUT
   type table_t is array(0 to (2**Nbit)-1) of std_logic_vector(Nbit-1 downto 0); -- LUT type

-- Function Sigmoidal: generates the Look-Up-Table for the sigmoid activation function:
-- margin: maximun value of x.
   function Sigmoidal(margin:real;Nbit:natural) return table_t is
         variable scale,x,y,w,t: real;
         variable u: integer;
         variable fbits: std_logic_vector(Nbit-1 downto 0);
         variable table: table_t;
      begin
         scale := (2.0*margin)/(2.0**Nbit);   -- Calculates gap between to points
         x := -margin;
         for idx in -(2**(Nbit-1)) to (2**(Nbit-1))-1 loop
            y := (fr/(1.0+exp(((-4.0*f0)/fr)*x)))-(fr/2.0);
            w := y*(2.0**(Nbit-1));           -- Shifts bits to the left
            t := round(w);
            u := integer(t);
            fbits := std_logic_vector(to_signed(u,Nbit));
            table(to_integer(to_unsigned(idx+(2**Nbit),Nbit))):= fbits;
            x := x+scale;
         end loop;
         return table;
   end Sigmoidal;
   signal Table: table_t := Sigmoidal(1.0,Nbit); -- Generation of the LUT (at synthesis time)

begin

   -- Description of the activation function
   dataIn <= to_integer(signed(inputs));

   Activation: process(clk,reset)
      begin
         if clk'event and clk = '1' then
            if reset = '1' then
               run_out <= '0';
               outputs <= (others => '0');
            else
               if run_in = '1' then
                  run_out <='1';
                  outputs <=Table(dataIn); -- Assigns output value from the LUT
               else
                  run_out <='0';
               end if;
            end if;
         end if;
    end process;
end Behavioral;
