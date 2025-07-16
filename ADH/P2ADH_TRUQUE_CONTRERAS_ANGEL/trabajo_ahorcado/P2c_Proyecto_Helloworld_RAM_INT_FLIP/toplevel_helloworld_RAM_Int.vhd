library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity toplevel is
    Port (      port_id : out std_logic_vector(7 downto 0);	--solo para depurar
           write_strobe : out std_logic;	 						--solo para depurar
            read_strobe : out std_logic;							--solo para depurar
               out_port : out std_logic_vector(7 downto 0);	--solo para depurar
                in_port : out std_logic_vector(7 downto 0);	--solo para depurar
						reset : in std_logic;
						  clk : in std_logic;
						   rx : in std_logic;
				         tx : out std_logic;
		     		      LED : out std_logic);	 --led de comprobacion y reset
end toplevel ;

architecture behavioral of toplevel is
----------------------------------------------------------------
-- declaracion del picoblaze
----------------------------------------------------------------
  component picoblaze
    Port (      address : out std_logic_vector(7 downto 0);
            instruction : in std_logic_vector(15 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
                  reset : in std_logic; 
						  clk : in std_logic);
    end component;

-----------------------------------------------------------------
-- declaracion de la ROM de programa
-----------------------------------------------------------------
  component programa_ahorcado
    Port (      address : in std_logic_vector(7 downto 0);
            		   dout : out std_logic_vector(15 downto 0);
                    clk : in std_logic);
    end component;

-----------------------------------------------------------------
-- Declaracion del periforico ahorcado
-----------------------------------------------------------------
	component peri_ahorcado
		Port( data_in: in std_logic_vector(7 downto 0);
            data_out : out std_logic_vector(7 downto 0);
				data_out2 : out std_logic_vector(7 downto 0);
				data_out3 : out std_logic_vector(7 downto 0);
				data_out4 : out std_logic_vector(7 downto 0);
				data_out5 : out std_logic_vector(7 downto 0);
				data_out6 : out std_logic_vector(7 downto 0);
            clk : in std_logic;
				port_id : in std_logic_vector(7 downto 0);
				writestrobe : in std_logic;
				readstrobe: std_logic;
				reset : in std_logic
				);
	end component;

-----------------------------------------------------------------
-- Declaracion del periferico contador de errores
-----------------------------------------------------------------
	component peri_contador_errores
		Port( data_in: in std_logic_vector(7 downto 0);
            data_out : out std_logic_vector(7 downto 0);
            clk : in std_logic;
				port_id : in std_logic_vector(7 downto 0);
				writestrobe : in std_logic;
				readstrobe: in std_logic;
				reset : in std_logic
				);
	end component;
	
-----------------------------------------------------------------		
-- Señales de salida del periferico ahorcado
signal dataout1, dataout2, dataout3, dataout4, dataout5 :  std_logic_vector(7 downto 0);	
signal dataout6 : std_logic_vector(7 downto 0);

-- Señales de salida del periferico contador de errores
signal dataout_errores : std_logic_vector(7 downto 0);

-----------------------------------------------------------------
-- Signals usadas para conectar el picoblaze y la ROM de programa
-----------------------------------------------------------------
signal     address : std_logic_vector(7 downto 0);
signal instruction : std_logic_vector(15 downto 0);
		
-----------------------------------------------------------------
-- Signals para debugging 
-----------------------------------------------------------------
signal readstrobe: std_logic;
signal writestrobe: std_logic;
signal portid: std_logic_vector(7 downto 0);
signal inport: std_logic_vector(7 downto 0);
signal outport: std_logic_vector(7 downto 0);
signal picoint: std_logic;

type ram_type is array (0 to 63) of std_logic_vector (7 downto 0);
signal RAM : ram_type := (
    x"0A", x"0D", x"50", x"41", x"4C", x"41", x"42", x"52", -- \n \r P A L A B R (0-7)
    x"41", x"3A", x"20", x"00", x"00", x"00", x"00", x"00", -- A : (espacio) + padding (8-15)
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- Espacio libre (16-23)
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- Espacio libre (24-31)
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- Espacio libre (32-39)
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- Espacio libre (40-47)
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- Espacio libre (48-55)
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"  -- Espacio libre (56-63)
);

signal rxbuff_out,RAM_out: std_logic_vector(7 downto 0);

begin

	LED <= reset; 	-- para comprobar la programacion encendemos
						--	un led cada vez que reseteamos

	read_strobe <= readstrobe;
	write_strobe <= writestrobe;
	port_id <= portid;
	in_port <= inport;
	out_port <= outport;
	picoint <= NOT rx;
 	
  processor: picoblaze
    port map(      address => address,
               instruction => instruction,
                   port_id => portid,
              write_strobe => writestrobe,
                  out_port => outport,
               read_strobe => readstrobe,
                   in_port => inport,
                 interrupt => picoint,
                     reset => reset,
                       clk => clk);

  periferico: peri_ahorcado
    port map(     data_in => outport,
               	    port_id => portid,
							 writestrobe => writestrobe,
							 readstrobe => readstrobe,
							 data_out => dataout1,
							 data_out2 => dataout2,
							 data_out3 => dataout3,
							 data_out4 => dataout4,
							 data_out5 => dataout5,
							 data_out6 => dataout6,
							 reset => reset,
                      clk => clk);

  periferico_errores: peri_contador_errores
    port map(     data_in => outport,
               	    port_id => portid,
							 writestrobe => writestrobe,
							 readstrobe => readstrobe,
							 data_out => dataout_errores,
							 reset => reset,
                      clk => clk);
							 
  program: programa_ahorcado
    port map(     address => address,
               	     dout => instruction,
                      clk => clk);


	--registra el bit tx del puerto de salida, por si este cambia
	txbuff:process(reset, clk)
	begin
		if (reset='1') then
			tx <= '1';
		elsif rising_edge(clk) then
			if (writestrobe = '1' and portid=x"FF") then
				tx <= outport(0);	
			end if;
		end if;
	end process;
	
	--añade 7ceros a rx para meterlos al puerto de entrada cuando se lea
	rxbuff:process(reset, clk)
	begin
		if (reset='1') then
			rxbuff_out <= (others=>'1');
		elsif rising_edge(clk) then
			if (readstrobe = '1' and portid =x"FF") then
				rxbuff_out <= rx & "0000000";	
			end if;		 
		end if;
	end process;
	
	-- Memoria RAM (escritura sincrona / lectura asincrona)
	process (clk)
	begin
		if (clk'event and clk = '1') then
			if (writestrobe = '1' and portid<x"40") then
				RAM(to_integer(unsigned(portid))) <= outport;
			end if;
		end if;
	end process;
	RAM_out <= RAM(to_integer(unsigned(portid)));
	
-- Multiplexor inport
inport <= RAM_out when (readstrobe = '1' and portid<=x"40") else
          rxbuff_out when (readstrobe = '1' and portid=x"FF") else
          dataout2 when (readstrobe = '1' and portid=x"41") else --letra1
          dataout3 when (readstrobe = '1' and portid=x"42") else --letra2
          dataout4 when (readstrobe = '1' and portid=x"43") else --letra3
          dataout5 when (readstrobe = '1' and portid=x"44") else --letra4
          dataout6 when (readstrobe = '1' and portid=x"45") else --letra5
          dataout1 when (readstrobe = '1' and portid=x"46") else --resultado_comparaciones
          dataout_errores when (readstrobe = '1' and portid=x"49") else --contador_errores
          dataout_errores when (readstrobe = '1' and portid=x"4A") else --resultado_actual (debug)
          x"00";
				
end behavioral;