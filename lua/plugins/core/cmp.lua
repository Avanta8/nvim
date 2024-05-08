local utils = require("core.utils")

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local border_opts = {
  border = "single",
  winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
}

return {
  { -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          },
        },
        build = (function()
          -- Build Step is needed for regex support in snippets
          -- This step is not supported in many windows environments
          -- Remove the below condition to re-enable on windows
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        opts = function()
          local types = require("luasnip.util.types")
          local ext_opt = {
            virt_text = { { "│", "Visual" } },
            virt_text_pos = "inline",
          }
          return {
            -- Display a cursor-like placeholder in unvisited nodes
            -- of the snippet.
            ext_opts = {
              [types.insertNode] = {
                unvisited = ext_opt,
              },
              [types.exitNode] = {
                unvisited = ext_opt,
              },
            },
          }
        end,
        config = function(_, opts)
          local luasnip = require("luasnip")

          luasnip.setup(opts)

          -- Use <C-c> to select a choice in a snippet.
          vim.keymap.set({ "i", "s" }, "<C-c>", function()
            if luasnip.choice_active() then
              require("luasnip.extras.select_choice")()
            end
          end, { desc = "Select choice" })

          vim.api.nvim_create_autocmd("ModeChanged", {
            group = utils.augroup("cancel_snippet"),
            desc = "Cancel the snippet session when leaving insert mode",
            pattern = { "s:n", "i:*" },
            callback = function(args)
              if
                luasnip.session
                and luasnip.session.current_nodes[args.buf]
                and not luasnip.session.jump_active
                and not luasnip.choice_active()
              then
                luasnip.unlink_current()
              end
            end,
          })
        end,
      },
      {
        "zbirenbaum/copilot-cmp",
        dependencies = { "zbirenbaum/copilot.lua" },
        opts = {},
      },
      {
        "zjp-CN/nvim-cmp-lsp-rs",
        opts = {},
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    opts = function()
      local luasnip = require("luasnip")
      local cmp = require("cmp")
      local types = require("cmp.types")
      local cmp_lsp_rs = require("cmp_lsp_rs")
      local comparators = cmp_lsp_rs.comparators

      ---@type table<integer, integer>
      local modified_priority = {
        [types.lsp.CompletionItemKind.Variable] = types.lsp.CompletionItemKind.Method,
        [types.lsp.CompletionItemKind.Snippet] = 0, -- top
        [types.lsp.CompletionItemKind.Keyword] = 0, -- top
        [types.lsp.CompletionItemKind.Text] = 100, -- bottom
      }
      ---@param kind integer: kind of completion entry
      local function modified_kind(kind)
        return modified_priority[kind] or kind
      end

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })

      return {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        preselect = cmp.PreselectMode.None,
        completion = { completeopt = "menu,menuone,noselect" },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(_, item)
            local icons = require("core.custom").icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            return item
          end,
        },
        experimental = {
          ghost_text = false,
        },
        view = {
          entries = {
            follow_cursor = true,
          },
        },
        window = {
          completion = cmp.config.window.bordered(border_opts),
          documentation = cmp.config.window.bordered(border_opts),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          -- { name = "copilot", priority = 500 },
          { name = "buffer" },
          { name = "path" },
          { name = "emoji" },
        }),
        -- https://github.com/pysan3/dotfiles/blob/9d3ca30baecefaa2a6453d8d6d448d62b5614ff2/nvim/lua/plugins/70-nvim-cmp.lua#L132-L162
        sorting = {
          -- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/compare.lua
          -- comparators = {
          --   cmp.config.compare.offset,
          --   cmp.config.compare.exact,
          --   function(entry1, entry2) -- sort by length ignoring "=~"
          --     local len1 = string.len(string.gsub(entry1.completion_item.label, "[=~()_]", ""))
          --     local len2 = string.len(string.gsub(entry2.completion_item.label, "[=~()_]", ""))
          --     if len1 ~= len2 then
          --       return len1 - len2 < 0
          --     end
          --   end,
          --   cmp.config.compare.recently_used,
          --   function(entry1, entry2) -- sort by cmp.config.compare kind (Variable, Function etc)
          --     local kind1 = modified_kind(entry1:get_kind())
          --     local kind2 = modified_kind(entry2:get_kind())
          --     if kind1 ~= kind2 then
          --       return kind1 - kind2 < 0
          --     end
          --   end,
          --   function(entry1, entry2) -- score by lsp, if available
          --     local t1 = entry1.completion_item.sortText
          --     local t2 = entry2.completion_item.sortText
          --     if t1 ~= nil and t2 ~= nil and t1 ~= t2 then
          --       return t1 < t2
          --     end
          --   end,
          --   cmp.config.compare.score,
          --   cmp.config.compare.order,
          -- },
          comparators = {
            cmp.config.compare.sort_text,
            comparators.inscope_inherent_import,
            -- cmp.config.compare.scopes,
            -- cmp.config.compare.kind,
          },
        },
        -- sorting = {
        --   comparators = {
        --     cmp.config.compare.offset,
        --     cmp.config.compare.exact,
        --     cmp.config.compare.score,
        --     cmp.config.compare.recently_used,
        --     cmp.config.compare.locality,
        --     cmp.config.compare.kind,
        --     cmp.config.compare.sort_text,
        --     cmp.config.compare.length,
        --     cmp.config.compare.order,
        --   },
        -- },
        -- sorting = {
        --   priority_weight = 1.0,
        --   comparators = {
        --     cmp.config.compare.exact,
        --     cmp.config.compare.locality,
        --     cmp.config.compare.recently_used,
        --     cmp.config.compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
        --     cmp.config.compare.offset,
        --     cmp.config.compare.order,
        --     cmp.config.compare.scopes, -- what?
        --     cmp.config.compare.sort_text,
        --     cmp.config.compare.kind,
        --   },
        -- },

        mapping = {
          ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),

          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),

          ["<C-g>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
          ["<C-e>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),

          ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

          ["<C-h>"] = cmp.mapping(function()
            if luasnip.jumpable(-1) then -- These ifs are unnecessary
              luasnip.jump(-1)
            end
          end, { "i", "s" }),
          ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
        },
      }
    end,
  },
}
