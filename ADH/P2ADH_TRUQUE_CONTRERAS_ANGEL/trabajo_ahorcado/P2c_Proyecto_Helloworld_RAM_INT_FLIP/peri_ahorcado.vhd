library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity peri_ahorcado is
  port (
    data_in     : in  std_logic_vector(7 downto 0);
    port_id     : in  std_logic_vector(7 downto 0);
    writestrobe : in  std_logic;
    readstrobe  : in  std_logic;                    --
    clk         : in  std_logic;
    reset       : in  std_logic;
    data_out    : out std_logic_vector(7 downto 0); -- Puerto principal de salida
    data_out2   : out std_logic_vector(7 downto 0); -- letra1
    data_out3   : out std_logic_vector(7 downto 0); -- letra2  
    data_out4   : out std_logic_vector(7 downto 0); -- letra3
    data_out5   : out std_logic_vector(7 downto 0); -- letra4
    data_out6   : out std_logic_vector(7 downto 0)  -- resultado comparacion
  );
end entity;

architecture Behavioral of peri_ahorcado is
  signal letra1     : std_logic_vector(7 downto 0) := (others => '0');
  signal letra2     : std_logic_vector(7 downto 0) := (others => '0');
  signal letra3     : std_logic_vector(7 downto 0) := (others => '0');
  signal letra4     : std_logic_vector(7 downto 0) := (others => '0');
  signal letra5     : std_logic_vector(7 downto 0) := (others => '0');
  signal aux_out    : std_logic_vector(3 downto 0) := (others => '0');
  signal resultado  : std_logic_vector(7 downto 0) := (others => '0');
  
begin

  -- Proceso unificado de escritura
  write_process: process(reset, clk)
  begin
    if reset = '1' then
      letra1 <= (others => '0');
      letra2 <= (others => '0');
      letra3 <= (others => '0');
      letra4 <= (others => '0');
      letra5 <= (others => '0');
      aux_out <= (others => '0');
      resultado <= (others => '0');
    elsif rising_edge(clk) then
      if writestrobe = '1' then
        case port_id is
          when x"41" => letra1 <= data_in;
          when x"42" => letra2 <= data_in;
          when x"43" => letra3 <= data_in;
          when x"44" => letra4 <= data_in;
          when x"45" => 
            letra5 <= data_in;
            -- Realizar comparacion inmediatamente despues de recibir letra5
            -- Bit 0: letra1 coincide
            if (letra1 = data_in) or (aux_out(3) = '1') then
              aux_out(3) <= '1';
            end if;
            -- Bit 1: letra2 coincide  
            if (letra2 = data_in) or (aux_out(2) = '1') then
              aux_out(2) <= '1';
            end if;
            -- Bit 2: letra3 coincide
            if (letra3 = data_in) or (aux_out(1) = '1') then
              aux_out(1) <= '1';
            end if;
            -- Bit 3: letra4 coincide
            if (letra4 = data_in) or (aux_out(0) = '1') then
              aux_out(0) <= '1';
            end if;
          when x"46" => 
            resultado <= "0000" & aux_out;  -- Captura resultado
          when others => null;
        end case;
      end if;
    end if;
  end process;

  -- Asignacion de salidas (siempre disponibles)
  data_out <= resultado;      -- Puerto 0x46: resultado de comparaciones
  data_out2 <= letra1;        -- Puerto 0x41: letra1
  data_out3 <= letra2;        -- Puerto 0x42: letra2
  data_out4 <= letra3;        -- Puerto 0x43: letra3
  data_out5 <= letra4;        -- Puerto 0x44: letra4
  data_out6 <= letra5;        -- Puerto 0x45: letra a comparar

end architecture Behavioral;