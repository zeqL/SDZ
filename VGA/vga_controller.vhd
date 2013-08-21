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

entity vga_controller is

port(	clk					: 	in std_logic;
		resetn				:	in std_logic;
		hsync_out			:	out std_logic;
		vsync_out			:	out std_logic;
		active_pxl_out		:	out std_logic;
		active_line_out	:	out std_logic;
		pxl_counter_out	:	out std_logic_vector(10 downto 0);
		line_counter_out	:	out std_logic_vector(9 downto 0)
	
);
end vga_controller;

--------------------------------------------------------------

architecture behavior of vga_controller is

signal pxl_counter	: 	integer range 0 to 1346;
signal line_counter	:	integer range 0 to 811;
signal hsync		:	std_logic;
signal vsync		:	std_logic;
signal active_pxl	:	std_logic;
signal active_line	:	std_logic;

signal rdm			:	integer range 0 to 6;
signal grid_col		:	integer range 0 to 32;
signal grid_row		:	integer range 0 to 32;
signal clk_60		:	integer range 0 to 128;

signal table_act	:	std_logic;

type ligne is array (0 to 16) of integer;
type table is array ( 0 to 12) of ligne;

signal GoL_table0 	: table := (others=> (others=> 0));
signal GoL_table1 	: table := (others=> (others=> 0));

begin

-- Clock generation
--
-- Here : 1024x768@60Hz
-- Main clock : 65 Mhz (pixel clock)
-- HSYNC : 
-- 		Front Porch : 24px
-- 		Sync Pulse	: 136px
--			Back Porch	: 160px
--			Active video: 1024px
--
-- VSYNC :
-- 		Front Porch : 3 lines
-- 		Sync Pulse	: 6 lines
--			Back Porch	: 29 lines
--			Active video: 768 lines

	process(clk,resetn)
	begin
		if(resetn='0') then
			pxl_counter 	<= 0;
			line_counter 	<= 0;
			hsync			<= '1';
			vsync			<= '1';

			elsif rising_edge(clk) then
		
			pxl_counter <= pxl_counter + 1;
			-- Hsync signal
			if (pxl_counter < 136) then
				hsync 		<= '0';
				active_pxl	<= '0';
			elsif (pxl_counter >= 136 and pxl_counter < 296) then
				hsync		<= '1';
				active_pxl	<= '0';
			elsif (pxl_counter >= 296 and pxl_counter < 1320) then
				hsync		<= '1';
				active_pxl	<= '1';
			elsif (pxl_counter >= 1320 and pxl_counter < 1344) then
				hsync		<= '1';
				active_pxl	<= '0';
			elsif (pxl_counter >= 1344) then
				pxl_counter	<= 0;
				active_pxl	<= '0';
				line_counter <= line_counter + 1;
			end if;
			
			-- Vsync signal
			if (line_counter < 6) then
				vsync 		<= '0';
				active_line	<= '0';
			elsif (line_counter >= 6 and line_counter < 35) then
				vsync		<= '1';
				active_line	<= '0';
			elsif (line_counter >= 35 and line_counter < 803) then
				vsync		<= '1';
				active_line	<= '1';
			elsif (line_counter >= 803 and line_counter < 806) then
				vsync		<= '1';
				active_line	<= '0';
			elsif (line_counter >= 806) then
				vsync 	<= '1';
				line_counter	<= 0;
				active_line	<= '0';
			end if;	
		end if;
	
	end process;	
	
hsync_out			<= hsync;
vsync_out			<= vsync;
active_line_out 	<= active_line;
active_pxl_out		<= active_pxl;
pxl_counter_out	<= std_logic_vector(to_unsigned(pxl_counter, 11));
line_counter_out	<= std_logic_vector(to_unsigned(line_counter, 10));
	

end behavior;

--------------------------------------------------------------