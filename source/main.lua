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
        font_small = gfx.font.new('font/SourceHanSansCN-M-20px'),
        direction = "U"
    },
    SC_R90 = {
        name = "SC_R90",
        font = gfx.font.new('font/SourceHanSerifCN-SemiBold-R90'),
        font_small = gfx.font.new('font/SourceHanSansCN-M-20px-R90'),
        direction = "R"
    },
    SC_L90 = {
        name = "SC_L90",
        font = gfx.font.new('font/SourceHanSerifCN-SemiBold-L90'),
        font_small = gfx.font.new('font/SourceHanSansCN-M-20px-L90'),
        direction = "L"
    },
    SC_180 = {
        name = "SC_180",
        font = gfx.font.new('font/SourceHanSerifCN-SemiBold-180'),
        font_small = gfx.font.new('font/SourceHanSansCN-M-20px-180'),
        direction = "D"
    },
    English = {
        name = "English",
        font = gfx.font.new('font/Roobert-20-Medium'),
        direction = "U"
    }
}

local font_en_small <const> = gfx.font.new('font/Roobert-11-Medium')

local MODES <const> = {
    "SC",
    "SC_R90",
    "SC_L90",
    "SC_180",
    "English",
}

local MODES_SIDEOPTION <const> = {
    "Chinese",
    "English",
    "KK advice",
    "Random",
}

local INDICATOR_DIRECTION_RELATION <const> = {
    L = 1,
    R = 4,
    U = 2,
    D = 3,
    X = 5,
}

local imagetable_indicator <const> = gfx.imagetable.new("img/indicator-sc-poem")
local imagetable_indicator_whitemask <const> = gfx.image.new("img/indicator-sc-poem-whitemask")
local image_instruction <const> = gfx.image.new("img/menu-instruction")
local white_mask_img <const> = gfx.image.new("img/white-mask")
local white_mask_img2 <const> = gfx.image.new("img/white-mask2")

local poem_table_sc <const> = json.decodeFile("text/poem_zh.json")
local poem_table_en = nil
local poem_table_kk_advice <const> = json.decodeFile("text/kk-quote.json")
local kk_counter = 5 -- update per 3 mins

local mode_choose = "SC"
local mode_choose_sideoption = "Chinese"
local invert_color = false
local debug_mode = false

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
        kk_counter = 5
        reload(current_seed)
    end

end


function draw_analog_clock()
    local time_now = playdate.getTime()
    local hour = time_now.hour
    if hour>12 then
        hour -= 12
    end
    local screen_angle_offset = -90
    if mode_choose == "SC_L90" then
        screen_angle_offset = -180        
    elseif mode_choose == "SC_180" then
        screen_angle_offset = -270
    elseif mode_choose == "SC_R90" then
        screen_angle_offset = 0
    end

    local hour_angle = mapValue(hour+(time_now.minute/60), 0, 12, 0, 360)
    local minute_angle = mapValue(time_now.minute, 0, 60, 0, 360)
    local hour_start_blank = 60
    local hour_length = 24 + hour_start_blank
    local minute_start_blank = 30
    local minute_length = 60 + minute_start_blank
    local hour_start_x, hour_start_y = getCoordinates(hour_angle+screen_angle_offset, hour_start_blank)
    local hour_end_x, hour_end_y = getCoordinates(hour_angle+screen_angle_offset, hour_length)
    local minute_start_x, minute_start_y = getCoordinates(minute_angle+screen_angle_offset, minute_start_blank)
    local minute_end_x, minute_end_y = getCoordinates(minute_angle+screen_angle_offset, minute_length)
    print(hour_angle, minute_angle)
    print(hour_start_x, hour_start_y, hour_end_x, hour_end_y)
    print(minute_start_x, minute_start_y, minute_end_x, minute_end_y)

    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(8)
    gfx.drawLine(hour_start_x, hour_start_y, hour_end_x, hour_end_y)
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    gfx.drawLine(minute_start_x, minute_start_y, minute_end_x, minute_end_y)
    white_mask_img2:draw(0,0)
    
end


-----------------------------------------------------------------

function render_sc_poem(time_str, random_seed)
    if mode_choose_sideoption == "KK advice" then
        if kk_counter < 3 then
            kk_counter += 1
            return
        else
            kk_counter = 0
        end
    end

    math.randomseed(random_seed)

    clean_screen()

    local poem_text = "nothing found"
    if mode_choose_sideoption == "Chinese" then
        local time_now_str = time_str
        if poem_table_sc[time_now_str] == nil then
            print(time_str.." not in json")
            return
        end
        local random_index = math.random(#poem_table_sc[time_now_str])
        poem_text = poem_table_sc[time_now_str][random_index]
    elseif mode_choose_sideoption == "KK advice" then
        poem_text = poem_table_kk_advice["kk_quote"][math.random(#poem_table_kk_advice["kk_quote"])]
        draw_analog_clock()
    end


    gfx.setFont(FONTS[mode_choose].font)
    local text_size = gfx.getTextSize("啊")
    local line_height = text_size * 1.6

    local max_text_height = 0
    local max_text_width = 5
    local enable_small_font_condition = false
    for i, j in ipairs(split_text(poem_text, '\n')) do
        local text_width = text_size * (#j//2)
        if text_width > max_text_width then
            max_text_width = text_width
        end
        max_text_height += line_height
    end
    if max_text_width > screenWidth-10 then
        max_text_width = screenWidth-12
        enable_small_font_condition = true
    end
    if max_text_height > screenHeight-20 then
        max_text_height = screenHeight-22
        enable_small_font_condition = true
    end
    if enable_small_font_condition then
        gfx.setFont(FONTS[mode_choose].font_small)
        text_size = gfx.getTextSize("啊")
        line_height = text_size * 1.6
    end

    max_text_height = math.floor(max_text_height)



    if mode_choose == "SC_L90" then
        local base_pos = {
            x = math.random(10, screenWidth - max_text_width),
            y = math.random(20, screenHeight - max_text_height),
        }

        for i, j in ipairs(split_text(poem_text, '\n')) do
            gfx.drawTextAligned(j, base_pos.x, base_pos.y + line_height * (i-1), kTextAlignment.left)
        end
    elseif mode_choose == "SC_R90" then
        local base_pos = {
            x = math.random(max_text_width, screenWidth-10),
            y = math.random(20, screenHeight - max_text_height),
        }

        for i, j in ripairs(split_text(poem_text, '\n')) do
            gfx.drawTextAligned(utf8_reverse(j), base_pos.x, base_pos.y + line_height * (i-1), kTextAlignment.right)
        end
    elseif mode_choose == "SC_180" then
        local base_pos = {
            x = math.random(max_text_width, screenWidth-10),
            y = math.random(20, screenHeight - max_text_height),
        }

        for i, j in ripairs(split_text(poem_text, '\n')) do
            gfx.drawTextAligned(utf8_reverse(j), base_pos.x, base_pos.y + line_height * (i-1), kTextAlignment.right)
        end
    elseif mode_choose == "SC" then
        local base_pos = {
            x = math.random(10, screenWidth - max_text_width),
            y = math.random(20, screenHeight - max_text_height),
        }

        for i, j in ipairs(split_text(poem_text, '\n')) do
            gfx.drawTextAligned(j, base_pos.x, base_pos.y + line_height * (i-1), kTextAlignment.left)
        end
    end

end


function render_en_poem(time_str, random_seed)
    if poem_table_en == nil then
        poem_table_en = json.decodeFile("text/poem_en.json")
    end

    math.randomseed(random_seed)
    
    local time_now_str = time_str
    if poem_table_en[time_now_str] == nil then
        print(time_str.." not in json")
        return
    end
    local random_index = math.random(#poem_table_en[time_now_str])
    local poem_text = poem_table_en[time_now_str][random_index]

    gfx.setFont(FONTS[mode_choose].font)
    local text_size = gfx.getTextSize("M")
    local line_height = text_size * 2

    local max_text_height = 0
    local max_text_width = 5
    for i, j in ipairs(split_text(poem_text, '\n')) do
        local text_width = text_size * #j
        if text_width > max_text_width then
            max_text_width = text_width
        end
        max_text_height += line_height
    end
    if max_text_width > screenWidth-10 then
        max_text_width = screenWidth-12
        -- small font type optimize
        gfx.setFont(font_en_small)
        line_height = line_height//1.2
    end
    if max_text_height > screenHeight-20 then
        max_text_height = screenHeight-22
    end

    clean_screen()
    local base_pos = {
        x = math.random(10, screenWidth - max_text_width),
        y = math.random(20, screenHeight - max_text_height),
    }
    for i, j in ipairs(split_text(poem_text, '\n')) do
        gfx.drawTextAligned(j, base_pos.x, base_pos.y + line_height * (i-1), kTextAlignment.left)
    end

end


function sidebar_setting()
    local menu = playdate.getSystemMenu()

    local modeMenuItem, error = menu:addOptionsMenuItem("Poem", MODES_SIDEOPTION, mode_choose_sideoption, function(value)
        print("Mode selected: ", value)
        apply_mode_choose_by_sideoption(value)
        mode_choose_sideoption = value
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


function apply_mode_choose_by_sideoption(value)
    -- ignore "Random"
    if value == "English" then
        mode_choose = "English"
    elseif value == "Chinese" then
        if not starts_with(mode_choose, "SC") then
            mode_choose = "SC"
        end
    elseif value == "KK advice" then
        mode_choose = "SC"
    end
end

function debug_mode_random_choose_poem()
    local debug_seed = playdate.getTime().millisecond
    math.randomseed(debug_seed)
    local debug_random_minute = math.random(0,59)
    if debug_random_minute<10 then
        last_time_str = string.format( "%d:0%d", math.random(0,23), debug_random_minute)
    else
        last_time_str = string.format( "%d:%d", math.random(0,23), debug_random_minute)
    end
    print("debug mode trigger: ", last_time_str)
    current_seed = debug_seed
    reload(debug_seed)
end

-----------------------------------------------------------------

function getCoordinates(angle, length)
    local radian = math.rad(angle)

    local x = length * math.cos(radian) + screenWidth/2
    local y = length * math.sin(radian) + screenHeight/2
    
    return x, y
end


function mapValue(old_value, old_min, old_max, new_min, new_max)
    return math.floor((old_value - old_min) * (new_max - new_min) / (old_max - old_min) + new_min)
end


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
    state.mode_choose_sideoption = mode_choose_sideoption
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
    mode_choose_sideoption = get_or_default(state, "mode_choose_sideoption", "string", MODES_SIDEOPTION[1])
	invert_color = get_or_default(state, "invert_color", "boolean", false)
end

local init = function ()

	playdate.display.setRefreshRate(1)
    playdate.setAutoLockDisabled(true)
    playdate.setMenuImage(image_instruction)

    -- Load the state
	load_state()
    sidebar_setting()

	-- Set the background color
	gfx.setBackgroundColor(gfx.kColorWhite)
	setInverted(invert_color)
end

function reload(random_seed)
    random_seed = random_seed or playdate.getTime().millisecond

    if mode_choose_sideoption == "Random" then
        local random_mode_index = math.random( #MODES_SIDEOPTION-1 )
        apply_mode_choose_by_sideoption(MODES_SIDEOPTION[random_mode_index])
        if random_index == 1 then
            setInverted(true)
        else
            setInverted(false)
        end
    end

    if starts_with(mode_choose, "SC") or starts_with(mode_choose, "KK") then
        render_sc_poem(last_time_str, random_seed)
    elseif mode_choose == "English" then
        render_en_poem(last_time_str, random_seed)
    end

end

------------------------------------------------------------

function playdate.update()
    if last_time_str ~= get_now_time_string() and (not debug_mode) then
        last_time_str = get_now_time_string()
        current_seed = playdate.getTime().millisecond
        reload(current_seed)
    end

    if playdate.buttonIsPressed( playdate.kButtonA ) or  playdate.buttonIsPressed( playdate.kButtonB ) then
        if starts_with(mode_choose, "SC") then
            playdate.display.setRefreshRate(30)
            switch_sc_poem_direction("start")
        elseif mode_choose == "English" then
            draw_indicator("X")
        end
    end

end


function playdate.AButtonUp()
    switch_sc_poem_direction("stop")
    playdate.display.setRefreshRate(1)
end

function playdate.BButtonUp()
    switch_sc_poem_direction("stop")
    playdate.display.setRefreshRate(1)
end

-- debug mode
-- function playdate.downButtonUp()
--     playdate.display.setRefreshRate(20)
--     debug_mode = true
--     debug_mode_random_choose_poem()
-- end
-- function playdate.upButtonUp()
--     debug_mode = false
--     playdate.display.setRefreshRate(1)
--     print("debug mode exist")
-- end

init()