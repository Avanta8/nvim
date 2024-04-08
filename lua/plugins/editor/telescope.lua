local utils = require("core.utils")

return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
      dependencies = utils.which_key_dep({
        ["<leader>ls"] = { name = "search" },
      }),
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
      },
    },
    lazy = false,
    keys = function()
      local builtin = require("telescope.builtin")
      local utils = require("telescope.utils")
      local themes = require("telescope.themes")

      return {
        {
          "<leader><space>",
          function()
            builtin.buffers({ sort_mru = true })
          end,
          desc = "Find buffer",
        },
        {
          "<leader>;",
          function()
            builtin.current_buffer_fuzzy_find(themes.get_dropdown({ previewer = false }))
          end,
          desc = "Fuzzy find in buffer",
        },

        -- stylua: ignore start

        -- file
        { "<leader>ff", builtin.find_files, desc = "Find file (cwd)" },
        { "<leader>fF", function() builtin.find_files({ cwd = utils.buffer_dir() }) end, desc = "Find file (buffer dir)" },
        { "<leader>fh", function() builtin.find_files({ hidden = true }) end, desc = "Find file (hidden)" },
        { "<leader>fH", function() builtin.find_files({ hidden = true, cwd = utils.buffer_dir() }) end, desc = "Find file (hidden) (buffer dir)" },
        { "<leader>fc", function() builtin.find_files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find config" },
        { "<leader>fr", builtin.oldfiles, desc = "Find recent files" },

        -- search text
        { "<leader>jj", builtin.live_grep, desc = "Grep (cwd)" },
        { "<leader>jJ", function() builtin.live_grep( {cwd = utils.buffer_dir()}) end, desc = "Grep (buffer dir)" },
        { "<leader>jf", function() builtin.live_grep( {grep_open_files = true}) end, desc = "Grep (current files)" },
        { "<leader>jw", builtin.grep_string, desc = "Grep by current word (cwd)" },
        { "<leader>jW", function() builtin.grep_string({ cwd = utils.buffer_dir() }) end, desc = "Grep by current word (buffer dir)" },
        { "<leader>jb", builtin.current_buffer_fuzzy_find, desc = "Search in buffer (fuzzy)" },

        -- search
        { '<leader>s"', builtin.registers, desc = "Registers (<C-e> to edit)" },
        { "<leader>sa", builtin.autocommands, desc = "Autocommands" },
        { "<leader>st", builtin.builtin, desc = "Telescope builtins" },
        { "<leader>sr", builtin.resume, desc = "Resume last search" },
        { "<leader>sh", builtin.help_tags, desc = "help" },
        { "<leader>sc", builtin.command_history, desc = "Command history" },
        { "<leader>sC", builtin.commands, desc = "Commands" },
        { "<leader>sk", builtin.keymaps, desc = "Keymaps" },
        { "<leader>sm", builtin.marks, desc = "Marks" },
        { "<leader>so", builtin.vim_options, desc = "Options" },
        { "<leader>sz", function() builtin.colorscheme({ enable_preview = true }) end, desc = "Pick colorscheme" },
        -- stylua: ignore end

        {
          "<leader>fp",
          function()
            builtin.find_files({ cwd = require("lazy.core.config").options.root })
          end,
          desc = "Find Plugin File",
        },
        {
          "<leader>jp",
          function()
            local files = {} ---@type table<string, string>
            for _, plugin in pairs(require("lazy.core.config").plugins) do
              repeat
                if plugin._.module then
                  local info = vim.loader.find(plugin._.module)[1]
                  if info then
                    files[info.modpath] = info.modpath
                  end
                end
                plugin = plugin._.super
              until not plugin
            end
            builtin.live_grep({
              default_text = "/",
              search_dirs = vim.tbl_values(files),
            })
          end,
          desc = "Find Lazy Plugin Spec",
        },
      }
    end,
    opts = function()
      local actions = require("telescope.actions")
      local action_set = require("telescope.actions.set")
      return {
        defaults = {
          prompt_prefix = "",
          initial_mode = "normal",
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
          mappings = {
            i = {
              ["<Tab>"] = actions.move_selection_next,
              ["<S-Tab>"] = actions.move_selection_previous,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-h>"] = actions.select_vertical,
              ["<C-p>"] = actions.preview_scrolling_up,
              ["<C-n>"] = actions.preview_scrolling_down,
              ["<C-u>"] = function(prompt_bufnr)
                action_set.shift_selection(prompt_bufnr, -8)
              end,
              ["<C-d>"] = function(prompt_bufnr)
                action_set.shift_selection(prompt_bufnr, 8)
              end,
            },
            n = {
              ["<Tab>"] = actions.move_selection_next,
              ["<S-Tab>"] = actions.move_selection_previous,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-h>"] = actions.select_vertical,
              ["<C-p>"] = actions.preview_scrolling_up,
              ["<C-n>"] = actions.preview_scrolling_down,
              ["<C-u>"] = function(prompt_bufnr)
                action_set.shift_selection(prompt_bufnr, -8)
              end,
              ["<C-d>"] = function(prompt_bufnr)
                action_set.shift_selection(prompt_bufnr, 8)
              end,
            },
          },
        },

        pickers = {
          buffers = {
            mappings = {
              n = {
                ["d"] = "delete_buffer",
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
