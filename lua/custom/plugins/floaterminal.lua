vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')
local state = {
  floating = {
    buf = -1,
    win = -1,
  },
}

local function open_floating_window(opts)
  opts = opts or {}

  -- Get the current editor's dimensions
  local ui = vim.api.nvim_list_uis()[1]
  local editor_width = ui.width
  local editor_height = ui.height

  -- Determine width and height (default to 80% of editor)
  local width = opts.width or math.floor(editor_width * 0.8)
  local height = opts.height or math.floor(editor_height * 0.8)

  -- Calculate the starting position to center the window
  local col = math.floor((editor_width - width) / 2)
  local row = math.floor((editor_height - height) / 2)

  -- Create a new scratch buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  -- Define window configuration
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal', -- Optional: removes number lines, etc.
    border = 'rounded', -- Optional: adds a border
  }

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = open_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.term()
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

-- Default behavior (80% size, centered)
vim.api.nvim_create_user_command('Floaterminal', toggle_terminal, {})
vim.keymap.set({ 'n', 't' }, '<leader>tt', toggle_terminal, { desc = '[T]oggle Floa[T]erminal' })
