----------------------------------------------------------------------------------
-- Company: CEI - UPM
-- Engineer: David Aledo
--
-- Create Date: 01.10.2015
-- Design Name: Configurable ANN
-- Pakage Name: layers_pkg
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: define array types for generics, functions to give them values from
--   string generics, and other help functions
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

--library proc_common_v3_00_a; -- Deprecated libray from XPS tool
--use proc_common_v3_00_a.proc_common_pkg.all;

package layers_pkg is

   -- Array types for generics:
   type int_vector is array (natural range <>) of integer; -- Generic integer vector
   type ltype_vector is array (integer range <>) of string(1 to 2); -- Layer type vector
   type ftype_vector is array (integer range <>) of string(1 to 6); -- Activation function type vector
   -- Note: these strings cannot be unconstrined

   -- Functions to assign values to vector types from string generics:
   -- Arguments:
   --    str_v : string to be converted
   --    n : number of elements of the vector
   -- Return: assigned vector
   function assign_ints(str_v : string; n : integer) return int_vector;
   function assign_ltype(str_v : string; n : integer) return ltype_vector;
   function assign_ftype(str_v : string; n : integer) return ftype_vector;

   -- Other functions:

   -- Argument: c : character to be checked
   -- Return: TRUE if c is 0, 1, 2, 3, 4, 5, 6, 7, 8 or 9
   function is_digit(c : character) return boolean;

   -- Base two logarithm for int_vector:
   -- Arguments:
   --    v : integer vector
   --    n : number of elements of the vector
   -- Return : integer vector of the base two logarithms of each elment of v
   function log2(v : int_vector; n : integer) return int_vector;

   -- Calculate the total weight and bias memory address length:
   -- Arguments:
   --    NumIn : number of inputs of the network
   --    NumN : number of neurons of each layer
   --    n : number of layers (number of elements of NumN)
   -- Return: total weight and bias memory address length (integer)
   function calculate_addr_l(NumIn : integer; NumN : int_vector; n : integer) return integer;

   -- Assign the weight and bias memory address lenght of each layer:
   -- Arguments:
   --    NumIn : number of inputs of the network
   --    NumN : number of neurons of each layer
   --    n : number of layers (number of elements of NumN and the return integer vector)
   -- Return: weight and bias memory address lenght of each layer (integer vector)
   function assign_addrl(NumIn : integer; NumN : int_vector; n : integer) return int_vector;

   -- Calculate the maximum of the multiplications of two vectors element by element
   -- Arguments:
   --    v1 : input vector 1
   --    v2 : input vector 2
   -- Return: maximum of the multiplications of two vectors element by element
   function calculate_max_mul(v1 : int_vector; v2 : int_vector) return integer;

   -- Returns the max value of the input integer vector:
   function calculate_max(v : int_vector) return integer;

   -- Adding needed functions from the deprecated libray proc_common_v3_00_a:
   function max2 (num1, num2 : integer) return integer;
   function log2(x : natural) return integer;

end layers_pkg;

package body layers_pkg is

   function max2 (num1, num2 : integer) return integer is
   begin
      if num1 >= num2 then
         return num1;
      else
         return num2;
      end if;
   end function max2;

-- Function log2 -- returns number of bits needed to encode x choices
--   x = 0  returns 0
--   x = 1  returns 0
--   x = 2  returns 1
--   x = 4  returns 2, etc.
   function log2(x : natural) return integer is
      variable i  : integer := 0;
      variable val: integer := 1;
   begin
      if x = 0 then
         return 0;
      else
         for j in 0 to 29 loop -- for loop for XST
            if val >= x then null;
            else
               i := i+1;
               val := val*2;
            end if;
         end loop;
     -- Fix per CR520627  XST was ignoring this anyway and printing a
     -- Warning in SRP file. This will get rid of the warning and not
     -- impact simulation.
     -- synthesis translate_off
       assert val >= x
         report "Function log2 received argument larger" &
                " than its capability of 2^30. "
         severity failure;
     -- synthesis translate_on
       return i;
     end if;
   end function log2;


   function is_digit(c : character) return boolean is
   begin
      case c is
         when '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' => return true;
         when others => return false;
      end case;
   end is_digit;

   -- Assign values to a integer vector from a string:
   -- Arguments:
   --    str_v : string to be converted
   --    n : number of elements of the vector
   -- Return: assigned integer vector
   function assign_ints(str_v : string; n : integer) return int_vector is
      variable i : integer := n-1;   ---- element counter
      variable d_power : integer := 1; -- decimal power
      variable ret : int_vector(n-1 downto 0) := (others => 0); -- return value
   begin
      for c in str_v'length downto 1 loop -- read every character in str_v
         if str_v(c) = ' ' then -- a space separates a new element
            assert i > 0
               report "Error in assign_ints: number of elements in string is greater than n."
               severity error;
            i := i -1; -- decrease element counter to start calculate a new element
            d_power := 1; -- reset the decimal power to 1
         else
            assert is_digit(str_v(c)) -- assert the new character is a digit
               report "Error in assign_ints: character " & str_v(c) & " is not a digit."
               severity error;
            -- add the value of the new charactar to the element calculation ( + ("<new_digit>" - "0") * d_power):
            ret(i) := ret(i) + (character'pos(str_v(c))-character'pos('0'))*d_power;
            d_power := d_power*10; -- increase the decimal power for the next digit
         end if;
      end loop;
      assert i = 0
         report "Error in assign_ints: number of elements in string is less than n."
         severity error;
      return ret;
   end assign_ints;

   -- Assign values to an activation function type vector from a string:
   -- Arguments:
   --    str_v : string to be converted
   --    n : number of elements of the vector
   -- Return: assigned activation function type vector
   function assign_ftype(str_v : string; n : integer) return ftype_vector is
      variable i : integer := 0; -- element counter
      variable l : integer := 1; -- element length counter
      variable ret : ftype_vector(n-1 downto 0) := (others => "linear"); -- return value
   begin
      for c in 1 to str_v'length loop -- read every character in str_v
         if str_v(c) = ' ' then -- a space separates a new element
            i := i +1; -- increase element counter to start calculate a new element
            l := 1; -- reset element length counter
         else
            ret(i)(l) := str_v(c);
            l := l +1; -- increase element length counter
         end if;
      end loop;
      assert i = n-1
         report "Error in assign_ftype: number of elements in string is less than n."
         severity error;
      return ret;
   end assign_ftype;

   -- Assign values to an layer type vector from a string:
   -- Arguments:
   --    str_v : string to be converted
   --    n : number of elements of the vector
   -- Return: assigned layer type vector
   function assign_ltype(str_v : string; n : integer) return ltype_vector is
      variable i : integer := 0; -- element counter
      variable l : integer := 1; -- element length counter
      variable ret : ltype_vector(n-1 downto 0) := (others => "SP"); -- return value
   begin
      for c in 1 to str_v'length loop
         if str_v(c) = ' ' then -- a space separates a new element
            i := i +1; -- increase element counter to start calculate a new element
            l := 1; -- reset element length counter
         else
            assert str_v(c) = 'P' or str_v(c) = 'S'
               report "Error in assign_ltype: character " & str_v(c) & " is not 'P' (parallel) or 'S' (serial)."
               severity error;
            ret(i)(l) := str_v(c);
            l := l +1; -- increase element length counter
         end if;
      end loop;
      assert i = n-1
         report "Error in assign_ltype: number of elements do not coincide with number of introduced elements."
         severity error;
      return ret;
   end assign_ltype;

   -- Calculate the total weight and bias memory address length:
   -- Arguments:
   --    NumIn : number of inputs of the network
   --    NumN : number of neurons of each layer
   --    n : number of layers (number of elements of NumN)
   -- Return: total weight and bias memory address length (integer)
   function calculate_addr_l(NumIn : integer; NumN : int_vector; n : integer) return integer is -- matrix + b_sel
      variable addr_l : integer := log2(NumIn)+log2(NumN(0)); -- return value. Initialized with the weight memory length of the first layer
   begin
      -- Calculate the maximum of the weight memory length:
      for i in 1 to n-1 loop
         addr_l := max2( addr_l, log2(NumN(i-1))+log2(NumN(i)) );
      end loop;
      addr_l := addr_l +1; -- add bias select bit
      return addr_l;
   end calculate_addr_l;

   -- Base two logarithm for int_vector:
   -- Arguments:
   --    v : integer vector
   --    n : number of elements of the vector
   -- Return : integer vector of the base two logarithms of each elment of v
   function log2(v : int_vector; n : integer) return int_vector is
      variable ret : int_vector(n-1 downto 0); -- return value
   begin
      -- for each element of v, calculate its base two logarithm:
      for i in 0 to n-1 loop
         ret(i) := log2(v(i));
      end loop;
      return ret;
   end log2;

   -- Assign the weight and bias memory address lenght of each layer:
   -- Arguments:
   --    NumIn : number of inputs of the network
   --    NumN : number of neurons of each layer
   --    n : number of layers (number of elements of NumN and the return integer vector)
   -- Return: weight and bias memory address lenght of each layer (integer vector)
   function assign_addrl(NumIn : integer; NumN : int_vector; n : integer) return int_vector is
      variable ret : int_vector(n-1 downto 0); -- return value
   begin
      ret(0) := log2(NumIn)+log2(NumN(0)); -- Weight memory length of the first layer
      for i in 1 to n-1 loop
         ret(i) := log2(NumN(i-1))+log2(NumN(i));
      end loop;
      return ret;
   end assign_addrl;

   -- Returns the max value of the input integer vector:
   function calculate_max(v : int_vector) return integer is
      variable ac_max : integer := 0; -- return value
   begin
      for i in 0 to v'length-1 loop
         ac_max := max2(ac_max,v(i));
      end loop;
      return ac_max;
   end calculate_max;

   -- Calculate the maximum of the multiplications of two vectors element by element
   -- Arguments:
   --    v1 : input vector 1
   --    v2 : input vector 2
   -- Return: maximum of the multiplications of two vectors element by element
   function calculate_max_mul(v1 : int_vector; v2 : int_vector) return integer is
      variable ac_max : integer := 0;
   begin
      assert v1'length = v2'length
         report "Error in calculate_max_mul: vector's length do not coincide."
         severity error;
      for i in 0 to v1'length-1 loop
         ac_max := max2(ac_max,v1(i)*v2(i));
      end loop;
      return ac_max;
   end calculate_max_mul;

end layers_pkg;
