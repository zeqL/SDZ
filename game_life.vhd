--------------------------------------------------------------
--
--
--	
--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.all;

--------------------------------------------------------------

entity game_life is

port(	clk					: 	in std_logic;
		resetn				:	in std_logic;
		active_pxl_in		:	in std_logic;
		active_line_in		:	in std_logic;
		pxl_counter_in		:	in std_logic_vector(10 downto 0);
		line_counter_in	:	in std_logic_vector(9 downto 0);
		red_out				:	out std_logic_vector(3 downto 0);
		blue_out				:	out std_logic_vector(3 downto 0);
		green_out			:	out std_logic_vector(3 downto 0)
	
);
end game_life;

--------------------------------------------------------------

architecture behavior of game_life is

signal pxl_counter	: 	integer range 0 to 1346;
signal line_counter	:	integer range 0 to 811;
signal active_pxl		:	std_logic;
signal active_line	:	std_logic;
signal red				: 	std_logic_vector(3 downto 0);
signal green			: 	std_logic_vector(3 downto 0);
signal blue				: 	std_logic_vector(3 downto 0);

signal grid_col		:	integer range 0 to 32;
signal grid_row		:	integer range 0 to 32;
signal clk_60			:	integer range 0 to 128;

signal table_act		:	std_logic;

type ligne is array (0 to 16) of integer;
type table is array ( 0 to 12) of ligne;

signal GoL_table0 	: table := (others=> (others=> 0));
signal GoL_table1 	: table := (others=> (others=> 0));

begin

pxl_counter		<= to_integer(UNSIGNED(pxl_counter_in));
line_counter	<= to_integer(UNSIGNED(line_counter_in));
active_pxl		<= active_pxl_in;
active_line		<= active_line_in;


	process(clk, resetn)
	
	begin
	
	if(resetn='0') then
			red			<= "0000";
			green			<= "0000";
			blue			<= "0000";
			grid_col		<= 0;
			grid_row		<= 0;
			GoL_table0(4)(12) <= 1;
			GoL_table0(4)(11) <= 1;
			GoL_table0(4)(10) <= 1;
			--GoL_table0(6)(8) <= 1;
			--GoL_table0(6)(7) <= 1;
			GoL_table0(7)(4) <= 1;
			GoL_table0(7)(5) <= 1;
			GoL_table0(7)(6) <= 1;
			GoL_table0(8)(5) <= 1;
			GoL_table0(8)(6) <= 1;
			GoL_table0(8)(7) <= 1;
			table_act	<= '0';
			clk_60	<= 1;
	
	elsif rising_edge(clk) then
		
		clk_60 <= clk_60 + 1;

			if(active_pxl='1' and active_line = '1') then
				-- Draw grid 
				if((pxl_counter - 296) mod 64 = 0 or (line_counter - 35) mod 64 = 0) then
					red			<= "0110";
					green			<= "1100";
					blue			<= "0000";
				else
					-- First buffer active
					if(table_act = '0') then
						-- Draw light blue case if cell is alive
						if(GoL_table0(grid_row)(grid_col) = 1) then
							red			<= "0100";
							green			<= "1100";
							blue			<= "1101";
							if(grid_col > 1 and grid_col < 15 and grid_row > 1 and grid_row < 11 and clk_60 >= 61) then
								case(GoL_table0(grid_row - 1)(grid_col-1) + GoL_table0(grid_row - 1)(grid_col) + GoL_table0(grid_row - 1)(grid_col+1) 
								+ GoL_table0(grid_row)(grid_col-1) + GoL_table0(grid_row)(grid_col+1)
								+ GoL_table0(grid_row + 1)(grid_col-1) + GoL_table0(grid_row + 1)(grid_col) + GoL_table0(grid_row + 1)(grid_col+1) ) is
								when 0  			=> GoL_table1(grid_row)(grid_col) <= 0;
								when 1 			=> GoL_table1(grid_row)(grid_col) <= 0;
								when 2 			=> GoL_table1(grid_row)(grid_col) <= 1;
								when 3			=> GoL_table1(grid_row)(grid_col) <= 1;
								when others		=> GoL_table1(grid_row)(grid_col) <= 0;
								end case;
							end if;
							
						else
							-- Draw grey case if cell is dead
							red			<= "1001";
							green			<= "1001";
							blue			<= "1001";
							
							if(grid_col > 1 and grid_col < 15 and grid_row > 1 and grid_row < 11 and clk_60 >= 61) then
								if ((GoL_table0(grid_row - 1)(grid_col-1) + GoL_table0(grid_row - 1)(grid_col) + GoL_table0(grid_row - 1)(grid_col+1) 
								+ GoL_table0(grid_row)(grid_col-1) + GoL_table0(grid_row)(grid_col+1)
								+ GoL_table0(grid_row + 1)(grid_col-1) + GoL_table0(grid_row + 1)(grid_col) + GoL_table0(grid_row + 1)(grid_col+1) )
								= 3) then
									GoL_table1(grid_row)(grid_col) <= 1;
								end if;
							end if;
						end if;						
					end if;
					
					-- Second buffer active
					if(table_act = '1') then
						-- Draw light blue case if cell is alive
						if(GoL_table1(grid_row)(grid_col) = 1) then
							red			<= "1100";
							green			<= "0000";
							blue			<= "0000";
							if(grid_col > 1 and grid_col < 15 and grid_row > 1 and grid_row < 11 and clk_60 >= 61) then
								case(GoL_table1(grid_row - 1)(grid_col-1) + GoL_table1(grid_row - 1)(grid_col) + GoL_table1(grid_row - 1)(grid_col+1) 
								+ GoL_table1(grid_row)(grid_col-1) + GoL_table1(grid_row)(grid_col+1)
								+ GoL_table1(grid_row + 1)(grid_col-1) + GoL_table1(grid_row + 1)(grid_col) + GoL_table1(grid_row + 1)(grid_col+1) ) is
								when 0  			=> GoL_table0(grid_row)(grid_col) <= 0;
								when 1 			=> GoL_table0(grid_row)(grid_col) <= 0;
								when 2 			=> GoL_table0(grid_row)(grid_col) <= 1;
								when 3			=> GoL_table0(grid_row)(grid_col) <= 1;
								when others		=> GoL_table0(grid_row)(grid_col) <= 0;
								end case;
							end if;				
						else
							-- Draw grey case if cell is dead
							red			<= "1001";
							green			<= "1001";
							blue			<= "1001";
							
							if(grid_col > 1 and grid_col < 15 and grid_row > 1 and grid_row < 11 and clk_60 >= 61) then
								if ((GoL_table1(grid_row - 1)(grid_col-1) + GoL_table1(grid_row - 1)(grid_col) + GoL_table1(grid_row - 1)(grid_col+1) 
								+ GoL_table1(grid_row)(grid_col-1) + GoL_table1(grid_row)(grid_col+1)
								+ GoL_table1(grid_row + 1)(grid_col-1) + GoL_table1(grid_row + 1)(grid_col) + GoL_table1(grid_row + 1)(grid_col+1) )
								= 3) then
									GoL_table0(grid_row)(grid_col) <= 1;
								end if;
							end if;
						end if;
					end if;
				end if;
			else	
				-- Display nothing
				red			<= "0000";
				green			<= "0000";
				blue			<= "0000";		
			end if;
		
		-- Increment grid column counter
		if((pxl_counter - 296) mod 64 = 0 and active_pxl = '1') then
			grid_col		<= grid_col + 1;
		end if;
		
		-- Reset grid column counter and increment grid row counter
		if(grid_col >= 16) then
			grid_col		<= 0;
			if((line_counter - 35) mod 64 = 0 and active_line = '1') then
				grid_row		<= grid_row + 1;
			end if;
		end if;
		
		-- Reset grid row counter and alternate active table (double buffer)
		if(grid_row >= 12) then 
			grid_row		<= 0;
			if(clk_60 >= 61) then
			table_act <= not table_act;
			end if;
		end if;
		
		-- Reset slow display counter
		if(clk_60 >= 61) then
			clk_60 <= 1;
		end if;
	
	end if;
	end process;
	
	
red_out			<= red;
green_out		<= green;
blue_out			<= blue;

end behavior;

--------------------------------------------------------------