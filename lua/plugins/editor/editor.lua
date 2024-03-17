local core_utils = require("core.utils")
local custom = require("core.custom")

return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    lazy = false,
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    opts = {
      options = {
        -- stylua: ignore
        close_command = function(n) require("mini.bufremove").delete(n, false) end,
        -- stylua: ignore
        right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local icons = require("core.custom").icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd("BufAdd", {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },

  -- Preview code in floating window
  {
    "rmagatti/goto-preview",
    opts = {},
  },

  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      -- stylua: ignore
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
  },

  {
    "Aasim-A/scrollEOF.nvim",
    opts = {},
  },

  -- Show file name top right
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    opts = {
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
      },
      render = function(props)
        local helpers = require("incline.helpers")
        local devicons = require("nvim-web-devicons")
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if filename == "" then
          filename = "[No Name]"
        end
        local ft_icon, ft_color = devicons.get_icon_color(filename)
        local modified = vim.bo[props.buf].modified
        return {
          ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
          " ",
          { filename, gui = modified and "bold,italic" or "bold" },
          " ",
          guibg = "#44406e",
        }
      end,
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    keys = function()
      local command = require("neo-tree.command")
      return {
        -- Reveal the current file, or if in an unsaved file, the current working directory.
        -- Taken from help docs
        {
          "<leader>fr",
          function()
            local reveal_file = vim.fn.expand("%:p")
            if reveal_file == "" then
              reveal_file = vim.fn.getcwd()
            else
              local f = io.open(reveal_file, "r")
              if f then
                f.close(f)
              else
                reveal_file = vim.fn.getcwd()
              end
            end
            command.execute({
              reveal_file = reveal_file, -- path to file or folder to reveal
              reveal_force_cwd = true, -- change cwd without asking if needed
            })
          end,
          desc = "Reveal file",
        },
        {
          "<leader>e",
          function()
            command.execute({ dir = vim.loop.cwd() })
          end,
          desc = "File explorer (cwd) (focus)",
        },
        {
          "<leader>fE",
          function()
            command.execute({ toggle = true, dir = vim.loop.cwd() })
          end,
          desc = "File explorer (cwd) (toogle)",
        },
        {
          "<leader>ge",
          function()
            command.execute({ source = "git_status" })
          end,
          desc = "Git explorer (focus)",
        },
        {
          "<leader>gE",
          function()
            command.execute({ source = "git_status", toggle = true })
          end,
          desc = "Git explorer (toggle)",
        },
        {
          "<leader>be",
          function()
            command.execute({ source = "buffers" })
          end,
          desc = "Buffer explorer (focus)",
        },
        {
          "<leader>bE",
          function()
            command.execute({ source = "buffers", toggle = true })
          end,
          desc = "Buffer explorer (toggle)",
        },
      }
    end,
    opts = {},
  },

  -- Peek line numbers
  {
    "nacro90/numb.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = function()
      local persistence = require("persistence")
      return {
        { "<leader>qs", persistence.load, desc = "Restore Session" },
        -- stylua: ignore
        { "<leader>ql", function() persistence.load({ last = true }) end, desc = "Restore Last Session" },
        { "<leader>qd", persistence.stop, desc = "Don't Save Current Session" },
      }
    end,
    opts = {
      options = { "buffers", "curdir", "folds", "help", "tabpages", "winsize", "terminal" },
    },
  },

  {
    "nmac427/guess-indent.nvim",
    opts = {},
  },

  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },

  -- Point to lsp diagnostics
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    keys = {
      -- stylua: ignore
      { "<leader>lj", function() vim.notify("Toggled lsp lines") require("lsp_lines").toggle() end, desc = "Toggle diagnostics lines" },
    },
    init = function()
      -- Initially start with diagnostic disabled. Manually toggle it on when needed.
      vim.diagnostic.config({ virtual_lines = false })
    end,
    opts = {},
  },

  -- Show diagnostics in top right corner instead of inline
  {
    "dgagn/diagflow.nvim",
    event = "LspAttach",
    opts = {
      scope = "line",
    },
  },

  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {},
  },

  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>fo", "<CMD>Oil<CR>", desc = "Oil" },
    },
    opts = {},
  },

  {
    "echasnovski/mini.files",
    keys = {
      {
        "<leader>fm",
        function()
          require("mini.files").open()
        end,
        desc = "Mini Files",
      },
    },
    opts = {},
  },

  {
    "SmiteshP/nvim-navic",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
      {
        "nvim-lualine/lualine.nvim",
        opts = function(_, opts)
          opts.sections = opts.sections or {}
          opts.sections.lualine_c = opts.sections.lualine_c or {}
          table.insert(opts.sections.lualine_c, {
            function()
              return require("nvim-navic").get_location()
            end,
            cond = function()
              return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
            end,
          })
        end,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = core_utils.augroup("navic_lsp_attach"),
        callback = function(event)
          local navic = require("nvim-navic")
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, event.buf)
          end
        end,
      })
    end,
    opts = {
      icons = custom.icons.kinds,
      highlight = true,
    },
  },

  {
    "SmiteshP/nvim-navbuddy",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = core_utils.augroup("navbuddy_lsp_attach"),
        callback = function(event)
          local navbuddy = require("nvim-navbuddy")
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client.server_capabilities.documentSymbolProvider then
            return
          end

          navbuddy.attach(client, event.buf)
          require("which-key").register({
            ["<leader>ln"] = { navbuddy.open, "Navbuddy" },
          }, { buffer = event.buf })
        end,
      })
    end,
    opts = function()
      return {
        icons = custom.icons.kinds,
      }
    end,
  },
}
