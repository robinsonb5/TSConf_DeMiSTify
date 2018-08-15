-------------------------------------------------------------------[28.07.2014]
-- KEYBOARD CONTROLLER USB HID scancode to Spectrum matrix conversion
-------------------------------------------------------------------------------
-- V0.1 	05.10.2011	первая версия
-- V0.2		16.03.2014	измененмия в key_f (активная клавиша теперь устанавливается в '1')
-- V1.0		24.07.2014	доработан под USB HID Keyboard
-- V1.1		28.07.2014	добавлены спец клавиши
-- WXEDA	10.03.2015  добавлен контроллер ps/2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keyboard is
port (
	CLK		: in  std_logic;
	RESET		: in  std_logic;
	A			: in  std_logic_vector(7 downto 0);
	KEYB		: out std_logic_vector(4 downto 0);
	KEYF		: out std_logic_vector(4 downto 0);
	SCANCODE	: out std_logic_vector(7 downto 0);
	PS2_KEY  : in  std_logic_vector(10 downto 0)
);
end keyboard;

architecture rtl of keyboard is

-- Internal signals
type key_matrix is array (11 downto 0) of std_logic_vector(4 downto 0);
signal keys		: key_matrix;
signal row0, row1, row2, row3, row4, row5, row6, row7 : std_logic_vector(4 downto 0);
signal scan		: std_logic_vector(7 downto 0);

-- ps/2 signals
signal pressrelease_n : std_logic;
signal pressrelease :  std_logic;

signal flg : std_logic;

begin

	-- Output addressed row to ULA
	row0 <= keys(0) when A(0) = '0' else (others => '1');
	row1 <= keys(1) when A(1) = '0' else (others => '1');
	row2 <= keys(2) when A(2) = '0' else (others => '1');
	row3 <= keys(3) when A(3) = '0' else (others => '1');
	row4 <= keys(4) when A(4) = '0' else (others => '1');
	row5 <= keys(5) when A(5) = '0' else (others => '1');
	row6 <= keys(6) when A(6) = '0' else (others => '1');
	row7 <= keys(7) when A(7) = '0' else (others => '1');
	KEYB <= row0 and row1 and row2 and row3 and row4 and row5 and row6 and row7;

	KEYF 		<= keys(9);
	SCANCODE	<= scan;
	
	pressrelease_n <= not ps2_key(9);
	pressrelease <= ps2_key(9);
	
	process (CLK) begin
		if rising_edge(CLK) then
			flg <= ps2_key(10);

			if RESET = '1' then
				keys(0) <= (others => '1');
				keys(1) <= (others => '1');
				keys(2) <= (others => '1');
				keys(3) <= (others => '1');
				keys(4) <= (others => '1');
				keys(5) <= (others => '1');
				keys(6) <= (others => '1');
				keys(7) <= (others => '1');
				keys(8) <= (others => '0');
				keys(9) <= (others => '0');
				scan <= (others => '0');
			else
				if flg /= ps2_key(10) then
					if (pressrelease = '1') then
						scan <= ps2_key(7 downto 0);
					else 
						scan <= (others => '1');
					end if;
				
					case ps2_key(7 downto 0) is
						when X"12" => keys(0)(0) <= pressrelease_n; -- Left  shift (CAPS SHIFT)
						when X"59" => keys(0)(0) <= pressrelease_n; -- Right shift (CAPS SHIFT)
						when X"1a" => keys(0)(1) <= pressrelease_n; -- Z
						when X"22" => keys(0)(2) <= pressrelease_n; -- X
						when X"21" => keys(0)(3) <= pressrelease_n; -- C
						when X"2a" => keys(0)(4) <= pressrelease_n; -- V

						when X"1c" => keys(1)(0) <= pressrelease_n; -- A
						when X"1b" => keys(1)(1) <= pressrelease_n; -- S
						when X"23" => keys(1)(2) <= pressrelease_n; -- D
						when X"2b" => keys(1)(3) <= pressrelease_n; -- F
						when X"34" => keys(1)(4) <= pressrelease_n; -- G

						when X"15" => keys(2)(0) <= pressrelease_n; -- Q
						when X"1d" => keys(2)(1) <= pressrelease_n; -- W
						when X"24" => keys(2)(2) <= pressrelease_n; -- E
						when X"2d" => keys(2)(3) <= pressrelease_n; -- R
						when X"2c" => keys(2)(4) <= pressrelease_n; -- T

						when X"16" => keys(3)(0) <= pressrelease_n; -- 1
						when X"1e" => keys(3)(1) <= pressrelease_n; -- 2
						when X"26" => keys(3)(2) <= pressrelease_n; -- 3
						when X"25" => keys(3)(3) <= pressrelease_n; -- 4
						when X"2e" => keys(3)(4) <= pressrelease_n; -- 5

						when X"45" => keys(4)(0) <= pressrelease_n; -- 0
						when X"46" => keys(4)(1) <= pressrelease_n; -- 9
						when X"3e" => keys(4)(2) <= pressrelease_n; -- 8
						when X"3d" => keys(4)(3) <= pressrelease_n; -- 7
						when X"36" => keys(4)(4) <= pressrelease_n; -- 6

						when X"4d" => keys(5)(0) <= pressrelease_n; -- P
						when X"44" => keys(5)(1) <= pressrelease_n; -- O
						when X"43" => keys(5)(2) <= pressrelease_n; -- I
						when X"3c" => keys(5)(3) <= pressrelease_n; -- U
						when X"35" => keys(5)(4) <= pressrelease_n; -- Y

						when X"5a" => keys(6)(0) <= pressrelease_n; -- ENTER
						when X"4b" => keys(6)(1) <= pressrelease_n; -- L
						when X"42" => keys(6)(2) <= pressrelease_n; -- K
						when X"3b" => keys(6)(3) <= pressrelease_n; -- J
						when X"33" => keys(6)(4) <= pressrelease_n; -- H

						when X"29" => keys(7)(0) <= pressrelease_n; -- SPACE
										  --keys(8)(4) <= pressrelease; -- kempston fire
						when X"14" => keys(7)(1) <= pressrelease_n; -- CTRL (Symbol Shift)
						when X"3a" => keys(7)(2) <= pressrelease_n; -- M
						when X"31" => keys(7)(3) <= pressrelease_n; -- N
						when X"32" => keys(7)(4) <= pressrelease_n; -- B

						-- Cursor keys
						when X"6b" => keys(0)(0) <= pressrelease_n; -- Left (CAPS 5)
									  keys(3)(4) <= pressrelease_n;
									  --keys(8)(1) <= pressrelease; -- kempston left
						when X"72" => keys(0)(0) <= pressrelease_n; -- Down (CAPS 6)
									  keys(4)(4) <= pressrelease_n;
									  --keys(8)(2) <= pressrelease; -- kempston down
						when X"75" => keys(0)(0) <= pressrelease_n; -- Up (CAPS 7)
									  keys(4)(3) <= pressrelease_n;
									  --keys(8)(3) <= pressrelease; -- kempston up
						when X"74" => keys(0)(0) <= pressrelease_n; -- Right (CAPS 8)
									  keys(4)(2) <= pressrelease_n;
									  --keys(8)(0) <= pressrelease; -- kempston right

						-- Other special keys sent to the ULA as key combinations
						when X"66" => keys(0)(0) <= pressrelease_n; -- Backspace (CAPS 0)
									  keys(4)(0) <= pressrelease_n;
						when X"58" => keys(0)(0) <= pressrelease_n; -- Caps lock (CAPS 2)
									  keys(3)(1) <= pressrelease_n;
						when X"0d" => keys(0)(0) <= pressrelease_n; -- Tab (CAPS SPACE)
										keys(7)(0) <= pressrelease_n;
						when X"49" => keys(7)(2) <= pressrelease_n; -- .
									  keys(7)(1) <= pressrelease_n;
						when X"4e" => keys(6)(3) <= pressrelease_n; -- -
									  keys(7)(1) <= pressrelease_n;
						when X"0e" => keys(3)(0) <= pressrelease_n; -- ` (EDIT)
									  keys(0)(0) <= pressrelease_n;
						when X"41" => keys(7)(3) <= pressrelease_n; -- ,
									  keys(7)(1) <= pressrelease_n;
						when X"4c" => keys(5)(1) <= pressrelease_n; -- ;
									  keys(7)(1) <= pressrelease_n;
						when X"52" => keys(5)(0) <= pressrelease_n; -- "
									  keys(7)(1) <= pressrelease_n;
						when X"5d" => keys(0)(1) <= pressrelease_n; -- :
									  keys(7)(1) <= pressrelease_n;
						when X"55" => keys(6)(1) <= pressrelease_n; -- =
									  keys(7)(1) <= pressrelease_n;
						when X"54" => keys(4)(2) <= pressrelease_n; -- (
									  keys(7)(1) <= pressrelease_n;
						when X"5b" => keys(4)(1) <= pressrelease_n; -- )
									  keys(7)(1) <= pressrelease_n;
						when X"4a" => keys(0)(3) <= pressrelease_n; -- ?
									  keys(7)(1) <= pressrelease_n;
						--------------------------------------------
				
						-- Soft keys
						when X"78" => keys(9)(1) <= pressrelease; -- F11
						when X"07" => keys(9)(0) <= pressrelease; -- F12

						-- Hardware keys
						when X"7c" => keys(9)(2) <= pressrelease;	-- PrtScr
						when X"7e" => keys(9)(3) <= pressrelease;	-- Scroll Lock
						when X"48" => keys(9)(4) <= pressrelease;	-- Pause
										
						when others => null;
					end case;
				end if;
			end if;
		end if;
	end process;

end architecture;
