import 'CoreLibs/graphics'
import "CoreLibs/ui"
import "CoreLibs/crank"
local gfx <const> = playdate.graphics
local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()

local FONTS <const> = {
    {
        name = "cn",
        font = gfx.font.new('font/')    
    },
    {
        name = "cn_r90",
        font = gfx.font.new('font/')    
    },
    {
        name = "cn_l90",
        font = gfx.font.new('font/')    
    },
    {
        name = "cn_180",
        font = gfx.font.new('font/')    
    },
    {
        name = "en",
        font = gfx.font.new('font/')    
    },

}

local MODES <const> = {
    "SC R90",
    "SC L90",
    "SC 180",
    "English"
}
local mode_choose = "SC R90"
local invert_color = false

-----------------------------------------------------------------

function RenderZhPoem()
    poem_table = json.decodeFile("text/zh_poem")
end


function RenderEnPoem()
    poem_table = json.decodeFile("text/en_poem")
end


function SidebarSetting()
    local menu = playdate.getSystemMenu()

    local modeMenuItem, error = menu:addOptionsMenuItem("Mode", MODES, function(value)
        print("Mode selected: ", value)
        mode_choose = value
    end)
    
    local invertMenuItem, error = menu:addCheckmarkMenuItem("Invert", false, function(value)
        print("Checkmark menu item value changed to: ", value)
        invert_color = value
        setInverted(invert_color)
    end)
end

-----------------------------------------------------------------


function setInverted(darkMode)
	inverted = darkMode
	playdate.display.setInverted(inverted)
end


-- Get a value from a table if it exists or return a default value
local getOrDefault = function (table, key, expectedType, default)
	local value = table[key]
	if value == nil then
		return default
	else
		if type(value) ~= expectedType then
			print("Warning: value for key " .. key .. " is type " .. type(value) .. " but expected type " .. expectedType)
			return default
		end
		return value
	end
end


-- Save the state of the game to the datastore
local saveState = function ()
	print("Saving state...")
	local state = {}
	state.invert_color = invert_color
	state.mode_choose = mode_choose
	playdate.datastore.write(state)
	print("State saved!")
end


-- Load the state of the game from the datastore
local loadState = function ()
	print("Loading state...")
	local state = playdate.datastore.read()
	if state == nil then
		print("No state found, using defaults")
        state = {}
	else
		print("State found!")
	end
	mode_choose = getOrDefault(state, "mode_choose", "string", MODES[1])
	invert_color = getOrDefault(state, "invert_color", "boolean", false)
end


local init = function ()
	playdate.display.setRefreshRate(1)

    -- Load the state
	loadState()
    SidebarSetting()

	-- Set the background color
	gfx.setBackgroundColor(gfx.kColorWhite)
	setInverted(inverted)
end


function playdate.update()

end


init()