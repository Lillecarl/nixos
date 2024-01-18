local wk = require("which-key")

local ts = require("telescope")
local tsa = require("telescope.actions")
local actions = tsa
local tsb = require("telescope.builtin")
local tsm = require("telescope.mappings")

local mappings = {
  i = {
    ["<C-n>"] = actions.move_selection_next,
    --["<C-j>"] = { actions.move_selection_next, desc = "TS: Move Sel Next" },
    ["<C-p>"] = actions.move_selection_previous,
    ["<C-k>"] = actions.move_selection_previous,

    ["<C-c>"] = actions.close,

    ["<Down>"] = actions.move_selection_next,
    ["<Up>"] = actions.move_selection_previous,

    ["<CR>"] = actions.select_default,
    ["<C-x>"] = actions.select_horizontal,
    ["<C-v>"] = actions.select_vertical,
    ["<C-t>"] = actions.select_tab,

    ["<C-u>"] = actions.preview_scrolling_up,
    ["<C-d>"] = actions.preview_scrolling_down,
    ["<C-f>"] = actions.preview_scrolling_left,
    --["<C-k>"] = actions.preview_scrolling_right,

    ["<PageUp>"] = actions.results_scrolling_up,
    ["<PageDown>"] = actions.results_scrolling_down,
    ["<M-f>"] = actions.results_scrolling_left,
    ["<M-k>"] = actions.results_scrolling_right,

    ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
    ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
    ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
    ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
    ["<C-l>"] = actions.complete_tag,
    ["<C-/>"] = actions.which_key,
    ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
    ["<C-w>"] = { "<c-s-w>", type = "command" },

    -- disable c-j because we dont want to allow new lines #2123
    --["<C-j>"] = actions.nop,
  },

  n = {
    ["<esc>"] = actions.close,
    ["<CR>"] = actions.select_default,
    ["<C-x>"] = actions.select_horizontal,
    ["<C-v>"] = actions.select_vertical,
    ["<C-t>"] = actions.select_tab,

    ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
    ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
    ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
    ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

    -- TODO: This would be weird if we switch the ordering.
    ["j"] = actions.move_selection_next,
    ["k"] = actions.move_selection_previous,
    ["H"] = actions.move_to_top,
    ["M"] = actions.move_to_middle,
    ["L"] = actions.move_to_bottom,

    ["<Down>"] = actions.move_selection_next,
    ["<Up>"] = actions.move_selection_previous,
    ["gg"] = actions.move_to_top,
    ["G"] = actions.move_to_bottom,

    ["<C-u>"] = actions.preview_scrolling_up,
    ["<C-d>"] = actions.preview_scrolling_down,
    ["<C-f>"] = actions.preview_scrolling_left,
    ["<C-k>"] = actions.preview_scrolling_right,

    ["<PageUp>"] = actions.results_scrolling_up,
    ["<PageDown>"] = actions.results_scrolling_down,
    ["<M-f>"] = actions.results_scrolling_left,
    ["<M-k>"] = actions.results_scrolling_right,

    ["?"] = actions.which_key,
  },
}

ts.setup({
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--vimgrep",
      "--hidden",
      "--follow",
    },
    default_mappings = mappings,
  },
})

---diagnostic disable-next-line: unused-local
local apply = tsm.apply_keymap
tsm.apply_keymap = function(prompt_bufnr, attach_mappings, buffer_keymap)
  apply(prompt_bufnr, attach_mappings, buffer_keymap)

  local opts = {
    buffer = prompt_bufnr,
    mode = "i",
    noremap = true,
    silent = true,
  }

  local imaps = {
    ["<C-j>"] = { tsa.move_selection_next, "TS: Select Next" },
  }
  print(vim.inspect(imaps))
  for k, v in pairs(imaps) do
    imaps[k] = {
      function()
        return v[1](prompt_bufnr)
      end,
      v[2],
    }
  end
  print(vim.inspect(imaps))
  wk.register(imaps, opts)

  wk.register({
    --["<C-j>"] = { tsa.move_selection_next(prompt_bufnr), "TS: Select Next" },
    --[[["<C-j>"] = { tsa.move_selection_next[1], "TS: Select Next" },
    ["<C-p>"] = { tsa.move_selection_previous[1] },
    ["<C-k>"] = { tsa.move_selection_previous[1] },

    ["<C-c>"] = { tsa.close },

    ["<Down>"] = { tsa.move_selection_next },
    ["<Up>"] = { tsa.move_selection_previous },

    ["<CR>"] = { tsa.select_default },
    ["<C-x>"] = { tsa.select_horizontal },
    ["<C-v>"] = { tsa.select_vertical },
    ["<C-t>"] = { tsa.select_tab },

    --["<C-u>"] = { tsa.preview_scrolling_up },
    --["<C-d>"] = { tsa.preview_scrolling_down },
    --["<C-f>"] = { tsa.preview_scrolling_left },
    --["<C-k>"] = { tsa.preview_scrolling_right },

    ["<PageUp>"] = { tsa.results_scrolling_up },
    ["<PageDown>"] = { tsa.results_scrolling_down },
    ["<M-f>"] = { tsa.results_scrolling_left },
    ["<M-k>"] = { tsa.results_scrolling_right },
    ["<Tab>"] = { tsa.results_scrolling_right },

    --["<Tab>"] = {
    --  function()
    --    tsa.toggle_selection()
    --    tsa.move_selection_worse()
    --  end,
    --},
    --["<S-Tab>"] = {
    --  function()
    --    tsa.toggle_selection()
    --    tsa.move_selection_better()
    --  end,
    --},
    --["<C-q>"] = {
    --  function()
    --    tsa.send_to_qflist()
    --    tsa.open_qflist()
    --  end,
    --},
    --["<M-q>"] = {
    --  function()
    --    tsa.send_selected_to_qflist()
    --    tsa.open_qflist()
    --  end,
    --},
    ["<C-l>"] = { tsa.complete_tag },
    ["<C-/>"] = { tsa.which_key },
    ["<C-_>"] = { tsa.which_key }, -- keys from pressing <C-/>
    --["<C-w>"] = { "<c-s-w>", type = "command" },

    -- disable c-j because we dont want to allow new lines #2123
    --["<C-j>"] = { tsa.nop },--]]
  }, {
    buffer = prompt_bufnr,
    mode = "i",
    noremap = true,
    silent = true,
  })
end

wk.register({
  f = {
    name = "Find",
    f = { tsb.find_files, "Find Files" },
    g = { tsb.live_grep, "Live Grep" },
    b = { tsb.buffers, "Buffers" },
    h = { tsb.help_tags, "Help Tags" },
    t = { "<cmd>Telescope<cr>", "Pickers" },
  },
}, { prefix = "<leader>" })
