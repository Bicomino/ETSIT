library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity peri_contador_errores is
  port (
    data_in     : in  std_logic_vector(7 downto 0);
    port_id     : in  std_logic_vector(7 downto 0);
    writestrobe : in  std_logic;
    readstrobe  : in  std_logic;
    clk         : in  std_logic;
    reset       : in  std_logic;
    data_out    : out std_logic_vector(7 downto 0)  -- Puerto principal de salida
  );
end entity;

architecture Behavioral of peri_contador_errores is
  signal resultado_actual   : std_logic_vector(3 downto 0) := (others => '0');
  signal resultado_anterior : std_logic_vector(3 downto 0) := (others => '0');
  signal contador_errores   : unsigned(7 downto 0) := (others => '0');
  -- signal reset_contador     : std_logic := '0';
  
begin

  -- Proceso principal de control de errores
  error_process: process(reset, clk)
  begin
    if reset = '1' then
      resultado_actual <= (others => '0');
      resultado_anterior <= (others => '0');
      contador_errores <= (others => '0');
      -- reset_contador <= '0';
    elsif rising_edge(clk) then
      if writestrobe = '1' then
        case port_id is
          -- Puerto 0x47: recibe resultado actual del periferico ahorcado
          when x"47" => 
            resultado_actual <= data_in(3 downto 0);
            
            -- Logica de incremento de errores:
            -- 1. Si resultado es 0000 (no adivino nada) -> incrementar
            -- 2. Si resultado es igual al anterior (no progreso) -> incrementar
            -- 3. Si resultado es diferente y no es 0000 -> no incrementar
            
            if (data_in(3 downto 0) = "0000") or 
               (data_in(3 downto 0) = resultado_anterior and resultado_anterior /= "0000") then
              -- Incrementar contador solo si no ha llegado al maximo
              if contador_errores < 255 then
                contador_errores <= contador_errores + 1;
              end if;
            end if;
            
            -- Actualizar resultado anterior para proxima comparacion
            resultado_anterior <= data_in(3 downto 0);
            
          -- Puerto 0x48: reset contador de errores (nueva palabra)
          -- when x"48" => 
            -- contador_errores <= (others => '0');
            -- resultado_anterior <= (others => '0');
            -- resultado_actual <= (others => '0');
            
          when others => null;
        end case;
      end if;
    end if;
  end process;

  -- Proceso de lectura
  read_process: process(port_id, readstrobe, contador_errores, resultado_actual)
  begin
    data_out <= (others => '0');  -- Valor por defecto
    
    if readstrobe = '1' then
      case port_id is
        -- Puerto 0x49: lee contador de errores
        when x"49" => 
          data_out <= std_logic_vector(contador_errores);
          
        -- Puerto 0x4A: lee resultado actual
        when x"4A" => -- debug
          data_out <= "0000" & resultado_actual;
          
        when others => 
          data_out <= (others => '0');
      end case;
    end if;
  end process;

end architecture Behavioral;