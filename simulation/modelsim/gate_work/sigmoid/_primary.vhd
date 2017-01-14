library verilog;
use verilog.vl_types.all;
entity sigmoid is
    port(
        data            : in     vl_logic_vector(31 downto 0);
        result          : out    vl_logic_vector(31 downto 0)
    );
end sigmoid;
