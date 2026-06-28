
-- Here is where you can define your own phrases to use with the language system. You can define phrases in different languages
-- by creating a file called sh_<language name>.lua (e.g sh_french.lua) in the languages/ folder.

-- You are encouraged to avoid using hardcoded strings when displaying any sort of text on the client. You should instead define
-- these phrases here, and use the L() function to return the text in the proper language. For example, L("serverWelcome") would
-- return a string with the text "Welcome to the server, <name>!" as defined below.

-- You can also use formatted strings in phrases. This will make the phrase require additional parameters to display correctly.
-- In the case of serverWelcome, it requires another string which should be the character's name. An example:
-- L("serverWelcome", "John Lua") would return a string with the text "Welcome to the server, John Lua!".

LANGUAGE = {
	wsMissingItem = "You don't have %s.",
	wsWorking = "Working...",
	wsBusy = "Workshop is working",
	wsYouMade = "You made %s.",
	wsFailed = "Failed to make item.",
	wsInventoryFull = "Your inventory was full, so %s was spawned on the ground.",
	wsReady = "Workshop ended it's work",
	wsTimeLeft = "Time left: %s",
	wsNoTool = "No tool",
	wsWorking = "Working...",

	-- ITEMS
	-- WORKSHOPS
	tea_maker = "Tea maker",
	tea_maker_desc = "A machine that makes tea. It requires water to work.",
	tea_maker_2 = "Tea maker2",
	tea_maker_desc_2 = "A machine that makes tea. It requires water to work.2",
	

	-- FOODSYSTEM
	fsFullMouth = "Your mouth is full.",
	fsDrinking = "Drinking...",
	fsEating = "Eating...",
	fsItemLost = "Item lost",
}
