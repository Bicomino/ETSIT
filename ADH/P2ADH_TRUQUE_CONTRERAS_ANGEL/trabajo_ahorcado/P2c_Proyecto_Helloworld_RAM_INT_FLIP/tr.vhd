library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tr is
    Port (operand : in std_logic_vector(7 downto 0);
          Y : out std_logic_vector(7 downto 0);
          clk : in std_logic);
end tr;

architecture low_level_definition of tr is
begin
    process (clk)
    begin
        if (clk'event and clk = '1') then
            -- Conversion directa usando los 4 bits inferiores
            case operand(3 downto 0) is
                when "0000" => Y <= "00110000"; -- '0' (ASCII 0x30)
                when "0001" => Y <= "00110001"; -- '1' (ASCII 0x31)
                when "0010" => Y <= "00110010"; -- '2' (ASCII 0x32)
                when "0011" => Y <= "00110011"; -- '3' (ASCII 0x33)
                when "0100" => Y <= "00110100"; -- '4' (ASCII 0x34)
                when "0101" => Y <= "00110101"; -- '5' (ASCII 0x35)
                when "0110" => Y <= "00110110"; -- '6' (ASCII 0x36)
                when "0111" => Y <= "00110111"; -- '7' (ASCII 0x37)
                when "1000" => Y <= "00111000"; -- '8' (ASCII 0x38)
                when "1001" => Y <= "00111001"; -- '9' (ASCII 0x39)
                when "1010" => Y <= "01000001"; -- 'A' (ASCII 0x41)
                when "1011" => Y <= "01000010"; -- 'B' (ASCII 0x42)
                when "1100" => Y <= "01000011"; -- 'C' (ASCII 0x43)
                when "1101" => Y <= "01000100"; -- 'D' (ASCII 0x44)
                when "1110" => Y <= "01000101"; -- 'E' (ASCII 0x45)
                when "1111" => Y <= "01000110"; -- 'F' (ASCII 0x46)
                when others => Y <= "00110000"; -- '0' por defecto
            end case;
        end if;
    end process;
end low_level_definition;