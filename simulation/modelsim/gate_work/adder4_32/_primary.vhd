library verilog;
use verilog.vl_types.all;
entity adder4_32 is
    port(
        data0x          : in     vl_logic_vector(31 downto 0);
        data1x          : in     vl_logic_vector(31 downto 0);
        data2x          : in     vl_logic_vector(31 downto 0);
        data3x          : in     vl_logic_vector(31 downto 0);
        result          : out    vl_logic_vector(33 downto 0)
    );
end adder4_32;
