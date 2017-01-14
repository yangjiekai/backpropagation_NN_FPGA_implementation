library verilog;
use verilog.vl_types.all;
entity NeuralHookup is
    port(
        clk             : in     vl_logic;
        sw              : in     vl_logic_vector(17 downto 0);
        key             : in     vl_logic_vector(3 downto 0);
        hexDisplays     : out    vl_logic_vector(7 downto 0)
    );
end NeuralHookup;
