return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, { desc = "Next Hunk" })
        map("n", "[h", gs.prev_hunk, { desc = "Prev Hunk" })

        -- Actions
        -- stylua: ignore start
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
        map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage buffer" })
        map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
        map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })

        map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
        map("n", "<leader>gd", gs.diffthis, { desc = "Diff this" })
        map("n", "<leader>gD", function() gs.diffthis("~") end, { desc = "Diff this ~" })

        map("n", "<leader>ge", gs.toggle_current_line_blame, { desc = "Toggle blame" })
        map("n", "<leader>gx", gs.toggle_deleted, { desc = "Toggle deleted" })
        -- stylua: ignore end

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
      end,
    },
  },

  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = { { "<leader>gg", "<CMD>LazyGit<CR>", desc = "lazygit" } },
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
  },
}
