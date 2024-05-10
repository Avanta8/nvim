local utils = require("core.utils")
local custom = require("core.custom")

local function get_diagnostic_count(buf, severity)
  return #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity[severity:upper()] })
end

local function get_color_from_hl(name, field)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  return string.format("%06x", hl[field])
end

local function get_normal_hl()
  -- vim.notify(tostring(vim.api.nvim_get_current_win()))
  if vim.api.nvim_win_get_config(0).relative == "" then
    return "Normal"
  else
    return "NormalFloat"
  end
end

return {
  -- Show file name top right
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    keys = function()
      local incline = require("incline")
      return {
        {
          "<leader>tI",
          function()
            vim.notify("Incline refresh", vim.log.levels.INFO)
            incline.refresh()
          end,
          desc = "Refresh incline",
        },
        {
          "<leader>ti",
          function()
            incline.toggle()
            vim.notify("Incline " .. (incline.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
          end,
          desc = "Toggle incline",
        },
      }
    end,
    opts = {
      hide = {
        cursorline = true,
      },
      window = {
        padding = 0,
        margin = {
          horizontal = {
            left = 5,
            right = 0,
          },
          vertical = 0,
        },
        overlap = {
          borders = true,
          statusline = true,
          tabline = true,
          winbar = true,
        },
        placement = {
          horizontal = "left",
          vertical = "top",
        },
        zindex = 1,
      },
      ignore = {
        unlisted_buffers = false,
        floating_wins = false,
        buftypes = { "nofile" },
        wintypes = {},
        filetypes = { "dashboard", "TelescopePrompt" },
      },

      render = function(props)
        local colors = require("catppuccin.palettes.macchiato")

        local buf = props.buf
        local win = props.win
        local focused = props.focused
        local modified = vim.bo[props.buf].modified

        local function get_diagnostic_count(severity)
          return #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[severity:upper()] })
        end

        local function diagnostic_sec()
          local group = "DiagnosticSignOk"
          for _, severity in ipairs({ "Error", "Warn", "Hint", "Info" }) do
            if get_diagnostic_count(severity) > 0 then
              group = "DiagnosticSign" .. severity
              break
            end
          end
          return {
            { "▌ ", group = group },
          }
        end

        local function name_sec()
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end

          local file_icon, file_color = require("nvim-web-devicons").get_icon_color(filename)

          local text_style = ""
          if focused then
            text_style = (text_style ~= "" and (text_style .. ",") or "") .. "bold"
          end
          if modified then
            text_style = (text_style ~= "" and (text_style .. ",") or "") .. "italic"
          end
          text_style = text_style or "None"

          return {
            { file_icon, guifg = file_color },
            { " " },
            { filename, gui = text_style },
          }
        end

        local function modified_sec()
          local text = "   "
          if modified then
            text = " ● "
          end
          return {
            {
              text,
              guifg = colors.green,
            },
          }
        end

        local text_color = focused and colors.rosewater or colors.overlay2

        return {
          diagnostic_sec(),
          name_sec(),
          modified_sec(),
          -- " " .. tostring(win) .. " ",

          " "
            .. tostring(vim.fn.win_id2win(win))
            .. " ",
          guifg = text_color,
          guibg = colors.crust,
        }
      end,
    },
    init = function()
      local incline = require("incline")
      -- By default, incline will not fully redraw under an OptionSet event. Even though
      -- a buffer may change from hidden to unhidden and so it should start to get rendered.
      -- Therefore here we manually trigger complete refresh.
      --
      -- NOTE: Disable this for now because it causes flickering issue with Zellij
      --
      -- vim.api.nvim_create_autocmd({ "OptionSet" }, {
      --   group = utils.augroup("incline"),
      --   -- pattern = "buflisted",
      --   callback = function(event)
      --     incline.refresh()
      --   end,
      -- })
      vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
        group = utils.augroup("incline"),
        callback = function(event)
          incline.refresh()
        end,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      extensions = { "neo-tree", "lazy", "mason", "quickfix" },

      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        refresh = {
          statusline = 100,
          winbar = 100,
        },
        disabled_filetypes = {
          "dashboard",
          winbar = { "help" },
        },
      },

      sections = {
        lualine_a = { { "mode", icon = "" } },
        lualine_b = {
          { "branch", icon = "" },
          {
            "diagnostics",
            always_visible = true,
            sections = { "hint", "info", "warn", "error" },
            symbols = {
              error = custom.icons.diagnostics.Error,
              warn = custom.icons.diagnostics.Warn,
              info = custom.icons.diagnostics.Info,
              hint = custom.icons.diagnostics.Hint,
            },
          },
          {
            "diff",
            symbols = {
              added = custom.icons.git.added,
              modified = custom.icons.git.modified,
              removed = custom.icons.git.removed,
            },
          },
        },
        lualine_c = { "filename", "navic" },
        lualine_x = {
          function()
            local reg = vim.fn.reg_recording()
            if reg == "" then
              return ""
            end
            return "recording to " .. reg
          end,
          "searchcount",
        },
        lualine_y = { "encoding", "fileformat", "filetype" },
        lualine_z = { "progress", "location" },
      },

      -- winbar = {
      --   lualine_a = {},
      --   lualine_b = {},
      --   lualine_c = {
      --     {
      --       function()
      --         return " "
      --       end,
      --       padding = { left = 20, right = 0 },
      --       separator = "",
      --       color = get_normal_hl,
      --     },
      --     {
      --       function()
      --         return "▌"
      --       end,
      --       separator = "",
      --       padding = { left = 0, right = 0 },
      --       color = function()
      --         local buf = vim.api.nvim_win_get_buf(0)
      --
      --         local group = "DiagnosticSignOk"
      --         for _, severity in ipairs({ "Error", "Warn", "Hint", "Info" }) do
      --           if get_diagnostic_count(buf, severity) > 0 then
      --             group = "DiagnosticSign" .. severity
      --             break
      --           end
      --         end
      --
      --         return { fg = get_color_from_hl(group, "fg") }
      --       end,
      --     },
      --     {
      --       "filetype",
      --       separator = "",
      --       padding = { left = 1, right = 0 },
      --       icon_only = true,
      --     },
      --     {
      --       "filename",
      --       separator = "",
      --       padding = { left = 0, right = 0 },
      --       file_status = false,
      --       newfile_status = false,
      --       color = function()
      --         local modified = vim.bo.modified
      --         return {
      --           fg = get_color_from_hl("WinBar", "fg"),
      --           gui = modified and "bold,italic" or "bold",
      --         }
      --       end,
      --     },
      --     {
      --       function()
      --         local modified = vim.bo.modified
      --         local text = " "
      --         if modified then
      --           text = "●"
      --         end
      --         return text
      --       end,
      --       color = function()
      --         return {
      --           fg = "LightGreen",
      --         }
      --       end,
      --       separator = "",
      --       padding = { left = 1, right = 0 },
      --     },
      --     {
      --       function()
      --         local winid = vim.api.nvim_get_current_win()
      --         local winnr = vim.api.nvim_win_get_number(winid)
      --
      --         local text
      --         if true then
      --           text = winid .. " " .. winnr
      --         else
      --           text = "" .. winnr
      --         end
      --
      --         return text
      --       end,
      --       separator = "",
      --       padding = { left = 3, right = 1 },
      --       color = function()
      --         return { fg = get_color_from_hl("WinBar", "fg") }
      --       end,
      --     },
      --     {
      --       padding = { left = 0, right = 0 },
      --       function()
      --         return " "
      --       end,
      --       separator = "",
      --       color = "Normal",
      --     },
      --   },
      --   lualine_x = {},
      --   lualine_y = {},
      --   lualine_z = {},
      -- },
      -- inactive_winbar = {
      --   lualine_a = {},
      --   lualine_b = {},
      --   lualine_c = {
      --     {
      --       function()
      --         return "▌"
      --       end,
      --       separator = "",
      --       padding = { left = 20, right = 0 },
      --       color = function()
      --         local buf = vim.api.nvim_win_get_buf(0)
      --
      --         local group = "DiagnosticSignOk"
      --         for _, severity in ipairs({ "Error", "Warn", "Hint", "Info" }) do
      --           if get_diagnostic_count(buf, severity) > 0 then
      --             group = "DiagnosticSign" .. severity
      --             break
      --           end
      --         end
      --
      --         return { fg = get_color_from_hl(group, "fg") }
      --       end,
      --     },
      --     {
      --       "filetype",
      --       separator = "",
      --       padding = { left = 1, right = 0 },
      --       icon_only = true,
      --     },
      --     {
      --       "filename",
      --       separator = "",
      --       padding = { left = 0, right = 0 },
      --       file_status = false,
      --       newfile_status = false,
      --       color = function()
      --         local modified = vim.bo.modified
      --         return {
      --           fg = get_color_from_hl("Normal", "fg"),
      --           gui = modified and "bold,italic" or "bold",
      --         }
      --       end,
      --     },
      --     {
      --       function()
      --         local modified = vim.bo.modified
      --         local text = " "
      --         if modified then
      --           text = "●"
      --         end
      --         return text
      --       end,
      --       color = function()
      --         return {
      --           fg = "LightGreen",
      --         }
      --       end,
      --       separator = "",
      --       padding = { left = 1, right = 0 },
      --     },
      --     {
      --       function()
      --         local winid = vim.api.nvim_get_current_win()
      --         local winnr = vim.api.nvim_win_get_number(winid)
      --
      --         local text
      --         if true then
      --           text = winid .. " " .. winnr
      --         else
      --           text = "" .. winnr
      --         end
      --
      --         return text
      --       end,
      --       separator = "",
      --       padding = { left = 3, right = 0 },
      --       color = function()
      --         return { fg = get_color_from_hl("Normal", "fg") }
      --       end,
      --     },
      --   },
      --   lualine_x = {},
      --   lualine_y = {},
      --   lualine_z = {},
      -- },

      tabline = {
        lualine_a = {
          -- {
          --   "tabs",
          --   mode = 3,
          --   path = 1,
          -- },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            "tabs",
            mode = 0,
          },
        },
      },
    },
  },

  {
    "luukvbaal/statuscol.nvim",
    event = "VimEnter",
    opts = function()
      local builtin = require("statuscol.builtin")
      return {
        relculright = true,
        setopt = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          {
            sign = {
              namespace = { "gitsigns" },
              maxwidth = 1,
              colwidth = 1,
            },
            click = "v:lua.ScSa",
          },
          {
            sign = {
              namespace = { "diagnostic" },
              maxwidth = 1,
              colwidth = 2,
            },
            click = "v:lua.ScSa",
          },
          { text = { " " } },
          { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
          { text = { " " } },
        },
        ft_ignore = {
          "help",
          "vim",
          "alpha",
          "dashboard",
          "neo-tree",
          "lazy",
          "minifiles",
        },
      }
    end,
  },
}
