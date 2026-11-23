local options = require("okcolors.config").options

local function read_json_file(file_name)
    local plugin_root = vim.fn.expand("<sfile>:p:h:h")
    local resolved_path = vim.fn.resolve(plugin_root .. "/data/" .. file_name)
    if not vim.startswith(resolved_path, plugin_root) then
        error("Attempted to access file outside plugin directory")
    end
    local content = vim.fn.readfile(resolved_path)
    local json_string = table.concat(content)
    return vim.fn.json_decode(json_string)
end

local variants = {
    smooth = read_json_file("okcolors-smooth.json"),
    sharp = read_json_file("okcolors-sharp.json"),
}

local colorscheme
if variants[options.variant] ~= nil then
    colorscheme = variants[options.variant]
else
    colorscheme = variants.smooth
end

local palette
if vim.o.background == "light" then
    palette = colorscheme.light
else
    palette = colorscheme.dark
end

local function tint_background(accent, amount)
    local channels = {}
    for i = 2, 6, 2 do
        local bg = tonumber(palette.bg:sub(i, i + 1), 16)
        local fg = tonumber(accent:sub(i, i + 1), 16)
        channels[#channels + 1] = math.floor(bg + (fg - bg) * amount + 0.5)
    end
    return string.format("#%02x%02x%02x", channels[1], channels[2], channels[3])
end

palette.diff_add = tint_background(palette.green, 0.2)
palette.diff_delete = tint_background(palette.red, 0.2)
palette.diff_change = tint_background(palette.blue, 0.2)
palette.diff_text = tint_background(palette.blue, 0.6)

return palette
