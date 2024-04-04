local custom = require("core.custom")
local utils = require("core.utils")

return {
  -- Preview code in floating window
  {
    "rmagatti/goto-preview",
    opts = {},
  },

  {
    "dnlhc/glance.nvim",
    opts = {
      -- preview_win_opts = {
      --   relative = "win",
      -- },
      border = {
        enable = true,
      },
      theme = {
        enable = true,
        mode = "brighten",
        -- mode = "darken",
      },
    },
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
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },

  -- Point to lsp diagnostics
  {
    -- enabled = false,
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    keys = function()
      return {
        {
          "<leader>te",
          function()
            require("lsp_lines").toggle()
            local enabled = vim.diagnostic.config(nil).virtual_lines
            vim.notify("Lsp lines " .. (enabled and "enabled" or "disabled"))
          end,
          desc = "Toggle diagnostics lines",
        },
      }
    end,
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
    keys = {
      {
        "<leader>td",

        function()
          vim.g.diagflow_enabled = not vim.g.diagflow_enabled
          vim.notify("Diagflow " .. (vim.g.diagflow_enabled and "enabled" or "disabled"), vim.log.levels.INFO)

          if vim.g.diagflow_enabled then
            -- Hack is required to make diagflow update
            vim.api.nvim_exec_autocmds("CursorMoved", {})
          else
            -- Remove all the current diagnostic highlights.
            local ns = vim.api.nvim_get_namespaces().DiagnosticsHighlight
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
              end
            end
          end
        end,

        desc = "Toggle diagflow",
      },
    },
    opts = {
      scope = "line",
      enable = function()
        return vim.g.diagflow_enabled
      end,
    },
    init = function()
      vim.g.diagflow_enabled = true
    end,
  },

  {
    "echasnovski/mini.files",
    keys = function()
      local files = require("mini.files")
      return {
        { "<leader>fm", files.open, desc = "Mini Files" },
        {
          "<leader>fM",
          function()
            files.open(vim.api.nvim_buf_get_name(0), false)
          end,
          desc = "Mini Files (buffer dir)",
        },
      }
    end,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowUpdate",
        callback = function(args)
          vim.wo[args.data.win_id].relativenumber = true
        end,
      })

      local files_set_cwd = function(path)
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        vim.fn.chdir(cur_directory)
        vim.notify("Set cwd to " .. cur_directory, vim.log.levels.INFO)
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          vim.keymap.set("n", "!", files_set_cwd, { buffer = args.data.buf_id, desc = "Set cwd" })
        end,
      })

      local map_split = function(buf_id, lhs, direction)
        local rhs = function()
          -- Make new window and set it as target
          local new_target_window
          vim.api.nvim_win_call(MiniFiles.get_target_window(), function()
            vim.cmd(direction .. " split")
            new_target_window = vim.api.nvim_get_current_win()
          end)

          MiniFiles.set_target_window(new_target_window)
        end

        -- Adding `desc` will result into `show_help` entries
        local desc = "Split " .. direction
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          map_split(buf_id, "gs", "belowright horizontal")
          map_split(buf_id, "gv", "belowright vertical")
        end,
      })
    end,

    opts = {
      windows = {
        preview = true,
        width_preview = 50,
      },
    },
  },

  {
    "SmiteshP/nvim-navic",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = utils.augroup("navic_lsp_attach"),
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
        group = utils.augroup("navbuddy_lsp_attach"),
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

  {
    enabled = false,
    "artemave/workspace-diagnostics.nvim",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = utils.augroup("workspace-diagnostics_attach"),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          require("workspace-diagnostics").populate_workspace_diagnostics(client, event.buf)
        end,
      })
    end,
    opts = {},
  },

  {
    "dstein64/nvim-scrollview",
    opts = {
      -- signs_on_startup = { "all" },
      --
      -- NOTE: There is an issue with enabling the scrollview for floating wins
      -- casusing an issue with dressing. Code actions are not displayed.
      -- So don't enable this for now.
      --
      -- floating_windows = true,
      diagnostics_error_symbol = custom.icons.diagnostics.Error,
      diagnostics_warn_symbol = custom.icons.diagnostics.Warn,
      diagnostics_hint_symbol = custom.icons.diagnostics.Hint,
      diagnostics_info_symbol = custom.icons.diagnostics.Info,
      zindex = 1,
    },
  },

  {
    "folke/trouble.nvim",
    branch = "dev",
    opts = {
      focus = true,
      win = {
        wo = {
          winhighlight = "",
        },
      },
      preview = {
        type = "split",
        relative = "win",
        position = "right",
        size = 0.5,
        wo = {
          winhighlight = "",
        },
      },
      icons = {
        kinds = custom.icons.kinds,
      },
      keys = {
        ["<c-s>"] = "jump_split",
        ["<c-h>"] = "jump_vsplit",
      },
      modes = {
        preview_float = {
          mode = "lsp_references",
          preview = {
            type = "float",
            relative = "editor",
            border = "rounded",
            title = "Preview",
            title_pos = "center",
            position = { 0, -2 },
            size = { width = 0.3, height = 0.3 },
            zindex = 200,
          },
        },
        test = {
          mode = "lsp_references",
          preview = {
            type = "split",
            relative = "win",
            position = "right",
            size = 0.3,
          },
        },
      },
    },
  },

  {
    "ariel-frischer/bmessages.nvim",
    opts = {},
  },

  {
    "AckslD/messages.nvim",
    opts = {},
  },

  {
    "HakonHarnes/img-clip.nvim",
    opts = {},
  },
}
