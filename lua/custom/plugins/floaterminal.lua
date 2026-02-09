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

local open_terminal = function()
  state.floating = open_floating_window { buf = state.floating.buf }
  if vim.bo[state.floating.buf].buftype ~= 'terminal' then
    vim.cmd.term()
  end
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    open_terminal()
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

local change_or_open_terminal = function(bufnr)
  if vim.api.nvim_win_is_valid(state.floating.win) then
    vim.api.nvim_win_hide(state.floating.win)
  end
  state.floating.buf = bufnr
  open_terminal()
end

local close_terminal = function()
  vim.api.nvim_win_hide(state.floating.win)
end

local open_telescope_floaterminal_picker = function(opts)
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local make_entry = require 'telescope.make_entry'
  local api = vim.api
  opts = opts or {}

  local bufnrs = vim.tbl_filter(function(bufnr)
    local bufname = api.nvim_buf_get_name(bufnr)
    local is_term = string.find(bufname, 'term://') == 1
    if is_term then
      return true
    end
    return false
  end, api.nvim_list_bufs())

  local buffers = {}
  for _, bufnr in ipairs(bufnrs) do
    local flag = bufnr == state.floating.buf and '' or ' '
    local element = {
      bufnr = bufnr,
      flag = flag,
      info = vim.fn.getbufinfo(bufnr)[1],
    }

    table.insert(buffers, element)
  end

  if not opts.bufnr_width then
    local max_bufnr = math.max(unpack(bufnrs))
    opts.bufnr_width = #tostring(max_bufnr)
  end

  pickers
    .new(opts, {
      prompt_title = 'Floaterminal Picker',
      finder = finders.new_table {
        results = buffers,
        entry_maker = opts.entry_maker or make_entry.gen_from_buffer(opts),
      },
      previewer = conf.grep_previewer(opts),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          change_or_open_terminal(action_state.get_selected_entry().bufnr)
        end)
        map({ 'i', 'n' }, '<M-d>', actions.delete_buffer)
        return true
      end,
    })
    :find()
end

-- Default behavior (80% size, centered)
vim.api.nvim_create_user_command('FloaterminalToggle', toggle_terminal, {})
vim.keymap.set({ 'n', 't' }, '<leader>tt', toggle_terminal, { desc = '[T]oggle Floa[T]erminal' })

-- Telescope Floaterminal picker
vim.api.nvim_create_user_command('FloaterminalTelescope', open_telescope_floaterminal_picker, {})
vim.keymap.set({ 'n', 't' }, '<leader>st', function()
  return open_telescope_floaterminal_picker()
end, { desc = '[S]earch Float[T]erminal' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', function()
  return vim.api.nvim_get_current_buf() == state.floating.buf and close_terminal() or vim.cmd.nohlsearch()
end)

return {}
