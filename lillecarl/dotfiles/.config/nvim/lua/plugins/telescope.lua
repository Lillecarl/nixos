local M = {}

function M.setup(config)
  local wk = require("which-key")

  local ts = require("telescope")
  local tsa = require("telescope.actions")
  local actions = tsa
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
      ["<C-/>"] = { tsa.which_key, "TS: WhichKey" },
      ["<C-_>"] = { tsa.which_key, "TS: WhichKey" },
    },
    n = {
      ["<esc>"] = { actions.close, "TS: Close" },
      ["<CR>"] = { actions.select_default, "TS: Select" },
      ["<C-x>"] = { actions.select_horizontal, "TS: Sel horizontal" },
      ["<C-v>"] = { actions.select_vertical, "TS: Sel vertical" },
      ["<C-t>"] = { actions.select_tab, "TS Sel tab" },

      ["<Tab>"] = { actions.toggle_selection + actions.move_selection_worse, "TS: Toggle sel worse" },
      ["<S-Tab>"] = { actions.toggle_selection + actions.move_selection_better, "TS: Toggle sel better" },
      ["<C-q>"] = { actions.send_to_qflist + actions.open_qflist, "TS: Send to qflist" },
      ["<M-q>"] = { actions.send_selected_to_qflist + actions.open_qflist, "TS: Send sel to qflist" },

      ["j"] = { actions.move_selection_next, "TS: Move sel next" },
      ["k"] = { actions.move_selection_previous, "TS: Move sel prev" },
      ["M"] = { actions.move_to_middle, "TS: Move to middle" },

      ["<Down>"] = { actions.move_selection_next, "TS: Move sel next" },
      ["<Up>"] = { actions.move_selection_previous, "TS: Move sel prev" },
      ["gg"] = { actions.move_to_top, "TS: Move to top" },
      ["G"] = { actions.move_to_bottom, "TS: Move to bottom" },

      ["<C-u>"] = { actions.preview_scrolling_up, "TS: Preview scroll up" },
      ["<C-d>"] = { actions.preview_scrolling_down, "TS: Preview scroll down" },
      ["<C-f>"] = { actions.preview_scrolling_left, "TS: Preview scroll left" },
      ["<C-k>"] = { actions.preview_scrolling_right, "TS: Preview scroll right" },

      ["<PageUp>"] = { actions.results_scrolling_up, "TS: Res scroll up" },
      ["<PageDown>"] = { actions.results_scrolling_down, "TS: Res scroll down" },
      ["<M-f>"] = { actions.results_scrolling_left, "TS: Res scrollt left" },
      ["<M-k>"] = { actions.results_scrolling_right, "TS: Res scrollt right" },

      ["?"] = { actions.which_key, "TS: WhichKey" },
    },
  }

  ts.setup({
    defaults = {
      --default_mappings = {},
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

  tsm.apply_keymapp = function(prompt_bufnr, _, _)
    for k1, _ in pairs(mappings) do
      local opts = {
        buffer = prompt_bufnr,
        mode = k1,
        noremap = true,
        silent = true,
      }

      for k2, v2 in pairs(mappings[k1]) do
        mappings[k1][k2] = {
          function()
            if type(v2[1]) == "function" then
              return v2[1]
            else
              ---@diagnostic disable-next-line: redundant-parameter
              return v2[1](prompt_bufnr)
            end
          end,
          v2[2],
        }
      end
      wk.register(mappings[k1], opts)
    end
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
end

return M
