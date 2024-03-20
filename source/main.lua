import 'CoreLibs/graphics'
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/sprites"
local gfx <const> = playdate.graphics
local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()

local FONTS <const> = {
    SC = {
        name = "SC",
        font = gfx.font.new('font/SourceHanSerifCN-SemiBold'),
        direction = "U"
    },
    SC_R90 = {
        name = "SC_R90",
        font = gfx.font.new('font/SourceHanSerifCN-SemiBold-R90'),
        direction = "R"
    },
    SC_L90 = {
        name = "SC_L90",
        font = gfx.font.new('font/SourceHanSerifCN-SemiBold-L90'),
        direction = "L"
    },
    SC_180 = {
        name = "SC_180",
        font = gfx.font.new('font/SourceHanSerifCN-SemiBold-180'),
        direction = "D"
    },
    English = {
        name = "English",
        font = gfx.font.new('font/SourceHanSerifCN-SemiBold'),
        direction = "U"
    },

}

local MODES <const> = {
    "SC",
    "SC_R90",
    "SC_L90",
    "SC_180",
    "English"
}

local INDICATOR_DIRECTION_RELATION <const> = {
    L = 1,
    R = 4,
    U = 2,
    D = 3,
}

local imagetable_indicator <const> = gfx.imagetable.new("img/indicator-sc-poem")
local imagetable_indicator_whitemask <const> = gfx.image.new("img/indicator-sc-poem-whitemask")

local poem_table_sc <const> = json.decodeFile("text/poem_zh.json")

local mode_choose = "SC"
local invert_color = false

local current_seed = math.randomseed(playdate.getTime().millisecond)
local last_time_str = ""

-----------------------------------------------------------------

function draw_indicator(direction)
    if direction == nil then
        direction = FONTS[mode_choose].direction
    end

    local pos = {
        x = screenWidth-85,
        y = screenHeight-85,
    }
    local index = INDICATOR_DIRECTION_RELATION[direction]

    imagetable_indicator_whitemask:draw(pos.x, pos.y)
    imagetable_indicator[index]:draw(pos.x, pos.y)
end


local direction_choose = FONTS[mode_choose].direction
function switch_sc_poem_direction(state)
    if state == "start" then

        if not playdate.accelerometerIsRunning() then
            draw_indicator(FONTS[mode_choose].direction)
            playdate.startAccelerometer()
        end

        x,y,z = playdate.readAccelerometer()

        function x_func(i)
            return i
        end

        function x_ne_func(i)
            return -i
        end

        if y > x_func(x) and y > x_ne_func(x) then
            direction_choose = "U"
            mode_choose = "SC"
        elseif y < x_func(x) and y > x_ne_func(x) then
            direction_choose = "L"
            mode_choose = "SC_L90"
        elseif y < x_func(x) and y < x_ne_func(x) then
            direction_choose = "D"
            mode_choose = "SC_180"
        elseif y > x_func(x) and y < x_ne_func(x) then
            direction_choose = "R"
            mode_choose = "SC_R90"
        end

        print("direction_choose:", direction_choose)
        draw_indicator(direction_choose)

    else
        playdate.stopAccelerometer()
        reload(current_seed)
    end

end

-----------------------------------------------------------------

function render_sc_poem(mode, time_str, random_seed)
    math.randomseed(random_seed)

    local time_now_str = time_str
    if poem_table_sc[time_now_str] == nil then
        print(time_str.." not in json")
        return
    end
    local random_index = math.random(#poem_table_sc[time_now_str])
    local poem_text = poem_table_sc[time_now_str][random_index]

    gfx.setFont(FONTS[mode_choose].font)
    local text_size = gfx.getTextSize("啊")
    local line_height = text_size * 1.6

    local max_text_height = 0
    local max_text_width = 5
    for i, j in ipairs(split_text(poem_text, '\n')) do
        local text_width = text_size * (#j//2)
        if text_width > max_text_width then
            max_text_width = text_width
        end
        max_text_height += line_height
    end
    if max_text_width > screenWidth then
        max_text_width = screenWidth-2
    end
    if max_text_height > screenHeight then
        max_text_height = screenHeight-2
    end


    clean_screen()
    if mode == "SC_L90" then
        local base_pos = {
            x = math.random(0, screenWidth - max_text_width) + 10,
            y = math.random(0, screenHeight - max_text_height) + 20,
        }

        for i, j in ipairs(split_text(poem_text, '\n')) do
            gfx.drawTextAligned(j, base_pos.x, base_pos.y + line_height * (i-1), kTextAlignment.left)
        end
    elseif mode == "SC_R90" then
        local base_pos = {
            x = math.random(max_text_width, screenWidth) - 10,
            y = math.random(0, screenHeight - max_text_height) + 20,
        }

        for i, j in ripairs(split_text(poem_text, '\n')) do
            gfx.drawTextAligned(utf8_reverse(j), base_pos.x, base_pos.y + line_height * (i-1), kTextAlignment.right)
        end
    elseif mode == "SC_180" then
        local base_pos = {
            x = math.random(max_text_width, screenWidth) - 10,
            y = math.random(0, screenHeight - max_text_height) + 20,
        }

        for i, j in ripairs(split_text(poem_text, '\n')) do
            gfx.drawTextAligned(utf8_reverse(j), base_pos.x, base_pos.y + line_height * (i-1), kTextAlignment.right)
        end
    elseif mode == "SC" then
        local base_pos = {
            x = math.random(0, screenWidth - max_text_width) + 10,
            y = math.random(0, screenHeight - max_text_height) + 20,
        }

        for i, j in ipairs(split_text(poem_text, '\n')) do
            gfx.drawTextAligned(j, base_pos.x, base_pos.y + line_height * (i-1), kTextAlignment.left)
        end
    end

end

function render_en_poem()
    -- poem_table = json.decodeFile("text/en_poem")
end


function sidebar_setting()
    local menu = playdate.getSystemMenu()

    local modeMenuItem, error = menu:addOptionsMenuItem("Mode", MODES, mode_choose, function(value)
        print("Mode selected: ", value)
        mode_choose = value
        save_state()
        reload(current_seed)
    end)
    
    local invertMenuItem, error = menu:addCheckmarkMenuItem("Invert", invert_color, function(value)
        print("Checkmark menu item value changed to: ", value)
        invert_color = value
        setInverted(invert_color)
        save_state()
    end)
end

-----------------------------------------------------------------


function utf8_reverse(input)
    local output = ""
    for code in string.gmatch(input,"[\1-\127\194-\244][\128-\191]*") do
      output = code .. output
    end
     return output
 end


 function ripairs(t)
    local r = {}
    for i = #t, 1, -1 do
        table.insert(r, t[i])
    end
    local function ripairs_it(r, i)
        i = i + 1
        local v = r[i]
        if v == nil then return nil
        else return i, v
        end
    end
    return ripairs_it, r, 0
end


function starts_with(str, start)
    return str:sub(1, #start) == start
 end


function get_now_time_string()
    local time_now = playdate.getTime()
    if time_now.minute < 10 then
        time_now_str = string.format("%d:0%d", time_now.hour, time_now.minute)
    else
        time_now_str = string.format("%d:%d", time_now.hour, time_now.minute)
    end    
    print(time_now_str)
    return time_now_str
end


function split_text(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
       table.insert(result, match);
    end
    return result;
 end


function setInverted(darkMode)
	inverted = darkMode
	playdate.display.setInverted(inverted)
end

function clean_screen()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, screenWidth, screenHeight)
end

-- Get a value from a table if it exists or return a default value
local get_or_default = function (table, key, expectedType, default)
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
function save_state()
	print("Saving state...")
	local state = {}
	state.invert_color = invert_color
	state.mode_choose = mode_choose
	playdate.datastore.write(state)
	print("State saved!")
end


-- Load the state of the game from the datastore
function load_state()
	print("Loading state...")
	local state = playdate.datastore.read()
	if state == nil then
		print("No state found, using defaults")
        state = {}
	else
		print("State found!")
	end
	mode_choose = get_or_default(state, "mode_choose", "string", MODES[1])
	invert_color = get_or_default(state, "invert_color", "boolean", false)
end

local init = function ()

	playdate.display.setRefreshRate(1)
    playdate.setAutoLockDisabled(true)

    -- Load the state
	load_state()
    sidebar_setting()

	-- Set the background color
	gfx.setBackgroundColor(gfx.kColorWhite)
	setInverted(inverted)
end

function reload(random_seed)
    random_seed = random_seed or playdate.getTime().millisecond

    if starts_with(mode_choose, "SC") then
        render_sc_poem(mode_choose, last_time_str, random_seed)
    elseif mode_choose == "English" then
        render_en_poem()
    end
end

------------------------------------------------------------

function playdate.update()
    if last_time_str ~= get_now_time_string() then
        last_time_str = get_now_time_string()
        current_seed = math.randomseed(playdate.getTime().millisecond)
        reload()
    end

    if playdate.buttonIsPressed( playdate.kButtonA ) then
        playdate.display.setRefreshRate(30)
        switch_sc_poem_direction("start")
    end
end


function playdate.AButtonUp()
    switch_sc_poem_direction("stop")
    playdate.display.setRefreshRate(1)
end

init()