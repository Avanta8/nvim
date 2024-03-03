return {
  {
    -- Using my fork instead because the original plugin is broken for wsl if you
    -- have appendWindowsPath = false set in wsl.conf
    "Avanta8/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    -- This is a workaround for the original plugin, but this ofc
    -- it breaks for other platforms.
    -- config = function()
    --   vim.api.nvim_exec2(
    --     [[
    --     function! g:OpenBrowser(url)
    --       silent exec '!"/mnt/c/Windows/System32/cmd.exe" /c start'a:url
    --     endfunction
    --   ]],
    --     {}
    --   )
    --   vim.g.mkdp_browserfunc = "g:OpenBrowser"
    -- end,
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "deno_fmt" },
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        deno = {},
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
      },
    },
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        -- Toggle check-boxes.
        ["<leader>lh"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true, desc = "Toggle Checkbox" },
        },
      },
      workspaces = {
        {
          name = "notes",
          path = "~/.notes",
        },
      },
    },
  },
}
