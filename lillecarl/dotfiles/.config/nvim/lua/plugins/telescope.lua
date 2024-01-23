local M = {}

function M.setup(config)
  local wk = require("which-key")

  local ts = require("telescope")
  local tsa = require("telescope.actions")
  local tsb = require("telescope.builtin")
  local tsm = require("telescope.mappings")

  local mappings = {
    i = {
      ["<C-j>"] = { tsa.move_selection_next, "TS: Move sel next" },
      ["<C-n>"] = { tsa.move_selection_next, "TS: Move sel next" },
      ["<C-p>"] = { tsa.move_selection_previous, "TS: Move sel prev" },
      ["<C-k>"] = { tsa.move_selection_previous, "TS: Move sel prev" },

      ["<C-c>"] = { tsa.close, "TS: Close" },

      ["<Down>"] = { tsa.move_selection_next, "TS: Move sel next" },
      ["<Up>"] = { tsa.move_selection_previous, "TS: Move sel prev" },

      ["<CR>"] = { tsa.select_default, "TS: Select" },
      ["<C-x>"] = { tsa.select_horizontal, "TS: Sel horizontal" },
      ["<C-v>"] = { tsa.select_vertical, "TS: Sel vertical" },
      ["<C-t>"] = { tsa.select_tab, "TS Sel tab" },

      ["<PageUp>"] = { tsa.results_scrolling_up, "TS: Res scroll up" },
      ["<PageDown>"] = { tsa.results_scrolling_down, "TS: Res scroll down" },
      ["<M-f>"] = { tsa.results_scrolling_left, "TS: Res scroll left" },
      ["<M-k>"] = { tsa.results_scrolling_right, "TS: Res scroll right" },

      ["<Tab>"] = { tsa.toggle_selection + tsa.move_selection_worse, "TS: Toggle sel worse" },
      ["<S-Tab>"] = { tsa.toggle_selection + tsa.move_selection_better, "TS: Toggle sel better" },
      ["<C-q>"] = { tsa.send_to_qflist + tsa.open_qflist, "TS: Send to qflist" },
      ["<M-q>"] = { tsa.send_selected_to_qflist + tsa.open_qflist, "TS: Send sel to qflist" },
      ["<C-l>"] = { tsa.complete_tag, "TS: Complete tag" },

      -- Unbind Telescope mappings that are unremovable
      ["<C-_>"] = { false, "TS: Which-Key" },
      ["<C-/>"] = { false, "TS: Which-Key" },

      ["<C-D>"] = { false, "TS: Preview scroll down" },
      ["<C-U>"] = { false, "TS: Preview scroll up" },
      ["<C-F>"] = { false, "TS: Preview scroll left" },
    },
    n = {
      ["<esc>"] = { tsa.close, "TS: Close" },
      ["<CR>"] = { tsa.select_default, "TS: Select" },
      ["<C-x>"] = { tsa.select_horizontal, "TS: Sel horizontal" },
      ["<C-v>"] = { tsa.select_vertical, "TS: Sel vertical" },
      ["<C-t>"] = { tsa.select_tab, "TS Sel tab" },

      ["<Tab>"] = { tsa.toggle_selection + tsa.move_selection_worse, "TS: Toggle sel worse" },
      ["<S-Tab>"] = { tsa.toggle_selection + tsa.move_selection_better, "TS: Toggle sel better" },
      ["<C-q>"] = { tsa.send_to_qflist + tsa.open_qflist, "TS: Send to qflist" },
      ["<M-q>"] = { tsa.send_selected_to_qflist + tsa.open_qflist, "TS: Send sel to qflist" },

      ["j"] = { tsa.move_selection_next, "TS: Move sel next" },
      ["k"] = { tsa.move_selection_previous, "TS: Move sel prev" },
      ["M"] = { tsa.move_to_middle, "TS: Move to middle" },

      ["<Down>"] = { tsa.move_selection_next, "TS: Move sel next" },
      ["<Up>"] = { tsa.move_selection_previous, "TS: Move sel prev" },
      ["gg"] = { tsa.move_to_top, "TS: Move to top" },
      ["G"] = { tsa.move_to_bottom, "TS: Move to bottom" },

      ["<C-u>"] = { tsa.preview_scrolling_up, "TS: Preview scroll up" },
      ["<C-d>"] = { tsa.preview_scrolling_down, "TS: Preview scroll down" },
      ["<C-f>"] = { tsa.preview_scrolling_left, "TS: Preview scroll left" },
      ["<C-k>"] = { tsa.preview_scrolling_right, "TS: Preview scroll right" },

      ["<PageUp>"] = { tsa.results_scrolling_up, "TS: Res scroll up" },
      ["<PageDown>"] = { tsa.results_scrolling_down, "TS: Res scroll down" },
      ["<M-f>"] = { tsa.results_scrolling_left, "TS: Res scrollt left" },
      ["<M-k>"] = { tsa.results_scrolling_right, "TS: Res scrollt right" },

      ["?"] = { tsa.which_key, "TS: WhichKey" },
    },
  }

  local ts_mappings = { ["i"] = {}, ["n"] = {} }

  for mode, mode_mappings in pairs(mappings) do
    for key, mapping in pairs(mode_mappings) do
      ts_mappings[mode][key] = mapping[1]
    end
  end

  local wk_mappings = { ["i"] = {}, ["n"] = {} }
  local un_mappings = { ["i"] = {}, ["n"] = {} }

  for mode, mode_mappings in pairs(mappings) do
    for key, mapping in pairs(mode_mappings) do
      if mapping[1] == false then
        un_mappings[mode][key] = "which_key_ignore"
      else
        wk_mappings[mode][key] = mapping[2]
      end
    end
  end

  ts.setup({
    mappings = ts_mappings,
    default_mappings = ts_mappings,
    defaults = {
      mappings = ts_mappings,
      default_mappings = ts_mappings,

      vimgrep_arguments = {
        config["tools"]["paths"]["ripgrep"],
        "--vimgrep",
        "--follow",
        "--hidden",
        "--ignore",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      },
    },
    pickers = {
      find_files = {
        find_command = {
          config["tools"]["paths"]["ripgrep"],
          "--follow",
          "--hidden",
          "--ignore",
          "--files",
        },
      },
    },
  })

  -- Overwrite apply_keymap to register mapping descriptions with which-key
  local apply_keymap_orig = tsm.apply_keymap
  tsm.apply_keymap = function(prompt_bufnr, attach_mappings, buffer_keymap)
    local wk_mappings_buf = {}

    -- Trying to map with Which-Key only
    if false == "wk_test" then
      wk_mappings_buf = vim.deepcopy(mappings)

      for mode, mode_mappings in pairs(wk_mappings_buf) do
        for key, mapping in pairs(mode_mappings) do
          wk_mappings_buf[mode][key] = {
            function()
              local key_func = mapping[1]
              return key_func(prompt_bufnr)
            end,
            mapping[2],
          }
        end
      end

      print(vim.inspect(wk_mappings_buf["i"]["<C-j>"]))

      for mode, mode_mappings in pairs(wk_mappings_buf) do
        wk.register(mode_mappings, { buffer = prompt_bufnr, mode = mode })
      end
    end

    -- Mapping keys with Telescope, setting descriptions with Which-Key
    if true then
      apply_keymap_orig(prompt_bufnr, attach_mappings, buffer_keymap)

      wk_mappings_buf = wk_mappings

      for mode, mode_mappings in pairs(wk_mappings_buf) do
        wk.register(mode_mappings, { buffer = prompt_bufnr, mode = mode })
      end
    end
  end

  local bindToBuffer = function(ev)
    local leader = {
      f = {
        name = "Find",
        f = { tsb.find_files, "Find Files" },
        g = { tsb.live_grep, "Live Grep" },
        b = { tsb.buffers, "Buffers" },
        h = { tsb.help_tags, "Help Tags" },
        t = { "<cmd>Telescope<cr>", "Pickers" },
      },
    }

    wk.register(leader, { prefix = "<leader>", buffer = ev.buf })
    wk.register(leader, { prefix = "<M-space>", buffer = ev.buf, mode = "i" })
  end

  vim.api.nvim_create_autocmd({ "User" }, {
    group = "RealBufferBind",
    callback = bindToBuffer,
  })

  vim.g.log = function(data)
    local file, err = io.open("/home/lillecarl/.local/share/nvim/disk", "a")
    if file then
      file:write(vim.inspect(data) .. "\n")
      file:flush()
    end
  end
end

return M
