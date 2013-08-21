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

entity GoL_top is

port(	clk_50_bin		: 	in std_logic;
		resetn_bin		:	in std_logic;
		led_bout			:	out std_logic;
		hsync_bout		:	out std_logic;
		vsync_bout		:	out std_logic;
		red_bout			:	out std_logic_vector(3 downto 0);
		blue_bout		:	out std_logic_vector(3 downto 0);
		green_bout		:	out std_logic_vector(3 downto 0)
	
);
end GoL_top;

--------------------------------------------------------------

architecture behavior of Gol_top is

signal	resetn	: 	std_logic;
signal	clk_50	:	std_logic;
signal	clk_65	: 	std_logic;
signal	pll_lock	: 	std_logic;
signal 	hsync		:	std_logic;
signal 	vsync		:	std_logic;
signal 	red		: 	std_logic_vector(3 downto 0);
signal 	green		: 	std_logic_vector(3 downto 0);
signal 	blue		: 	std_logic_vector(3 downto 0);

signal	active_pxl		: std_logic;
signal	active_line		: std_logic;
signal	pxl_counter		: std_logic_vector(10 downto 0);
signal	line_counter	: std_logic_vector(9 downto 0);

begin

PLL1 : entity work.pll port map(
		inclk0	=> clk_50,	
		c0			=> clk_65,
		locked	=> pll_lock
		);

VGA_CTRL1 : entity work.vga_controller port map(
		clk					=> clk_65,
		resetn				=>	resetn,
		hsync_out			=>	hsync,
		vsync_out			=>	vsync,
		active_pxl_out		=> active_pxl,
		active_line_out	=>	active_line,
		pxl_counter_out	=>	pxl_counter,
		line_counter_out	=> line_counter
		);

GoL_ent	: entity work.game_life port map(	
		clk					=> clk_65,
		resetn				=> resetn,
		active_pxl_in		=> active_pxl,
		active_line_in		=>	active_line,
		pxl_counter_in		=>	pxl_counter,
		line_counter_in	=>	line_counter,
		red_out				=> red,
		blue_out				=>	blue,
		green_out			=>	green
	
);		
		
clk_50	<= clk_50_bin;
resetn	<= resetn_bin;

hsync_bout	<= hsync;
vsync_bout	<=	vsync;
red_bout		<= red;
green_bout	<= green;
blue_bout	<= blue;

led_bout		<= '1' when resetn = '1' else '0';
	
	

end behavior;

--------------------------------------------------------------