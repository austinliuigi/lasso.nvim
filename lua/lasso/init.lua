local lasso = {}
local pre_yank_view, reg;

local function pre_yank()
  pre_yank_view = vim.fn.winsaveview()
  reg = vim.v.register
end

local function escape_quotes(str)
  return str:gsub('"', '\\"'):gsub("'", "\\'")
end

local function get_command(type, reg)
  local commands = {
    char = '`[v`]"'..reg..'y',
    line = vim.api.nvim_replace_termcodes(":'[,']y "..reg.."<CR>", true, true, true),
    block = vim.api.nvim_replace_termcodes('`[<C-v>`]"'..reg..'y', true, true, true)
  }
  return escape_quotes(commands[type])
end

lasso.yank = function(type)
  -- Run this only when called with mapping (not dot-repeat)
  if type == nil then
    vim.o.operatorfunc = "v:lua.require'lasso'.yank"
    return "g@"
  end
  -- Note: calling pre_yank here fails because cursor already moves to beginning of range
  -- Dot repeat does not work (can't store initial position before pressing `.`)
  local command = get_command(type, reg)
  vim.cmd(string.format([[silent execute "keepjumps normal! %s"]], command))
  vim.fn.winrestview(pre_yank_view)
end

lasso.setup = function(config)
  config = config or { 
    default_mappings = true
  }

  if config.default_mappings then
    vim.keymap.set({"n", "x"}, "y", function()
      pre_yank()
      return lasso.yank()
    end, { expr = true })
    vim.keymap.set("n", "yy", "yy", {remap = false})
  end
end

return lasso
