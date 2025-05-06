library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sma_filter is
    generic (
        N    : integer := 4;     
        SIZE : integer := 8      
    );
    port (
        clk  : in  std_logic;                     
        rst  : in  std_logic;                      
        din  : in  std_logic_vector(SIZE-1 downto 0);  
        load : in  std_logic;                      
        dout : out std_logic_vector(SIZE-1 downto 0)  
    );
end entity sma_filter;

architecture behavioral of sma_filter is
    type sam_arr is array (0 to N-1) of unsigned(SIZE-1 downto 0);
    signal samples : sam_arr := (others => (others => '0'));
    signal sum     : unsigned(SIZE+1 downto 0) := (others => '0');  
    signal count   : integer range 0 to N := 0;
begin
    process(clk, rst)
        variable aux : unsigned(SIZE+1 downto 0);
    begin
        if rst = '1' then
            samples <= (others => (others => '0'));
            sum <= (others => '0');
            count <= 0;
            dout <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                if count < N then
                    samples(count) <= unsigned(din);
                    sum <= sum + unsigned(din);
                    count <= count + 1;
                else
                    sum <= sum - samples(0) + unsigned(din);
                    
                    for i in 0 to N-2 loop
                        samples(i) <= samples(i+1);
                    end loop;
                    samples(N-1) <= unsigned(din);
                end if;
                
                if count > 0 then
                    aux := sum;
                    if count < N then
                        dout <= std_logic_vector(aux(SIZE-1+2 downto 2) / to_unsigned(count, 2));
                    else
                        dout <= std_logic_vector(aux(SIZE+1 downto 2));  
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture behavioral;