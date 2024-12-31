M = {}

function M.setup(cfg)
  return {
    "which-key",
    event = "DeferredUIEnter",
    -- keys = {
    --   {
    --     mode = { "v", "n" },
    --     "<leader>~",
    --     function()
    --       require("which-key").show({
    --         keys = "<c-w>",
    --         loop = true,
    --       })
    --     end,
    --     desc = "Global Keymaps (which-key)",
    --   },
    --   {
    --     mode = { "v", "n" },
    --     "<leader>/",
    --     function()
    --       require("which-key").show()
    --     end,
    --     desc = "Global Keymaps (which-key)",
    --   },
    --   {
    --     mode = { "v", "n" },
    --     "<leader>?",
    --     function()
    --       require("which-key").show({ global = false })
    --     end,
    --     desc = "Buffer Local Keymaps (which-key)",
    --   },
    -- },
    after = function()
      local wk = require("which-key")
      wk.setup({
        preset = "helix",
      })

      wk.add({
        mode = { "n" },
        { "v", hidden = true },
        {
          "<leader>/",
          function()
            wk.show({})
          end,
          desc = "Global keymaps",
        },
        {
          "<leader>?",
          function()
            wk.show({ global = false })
          end,
          desc = "Buf local keymaps",
        },
      })
    end,
  }
end

return M
