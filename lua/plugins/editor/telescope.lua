local core_utils = require("core.utils")
return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
      dependencies = core_utils.which_key_dep({
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

      return {
        { "<leader><space>", builtin.buffers, desc = "Find buffer" },
        {
          "<leader>/",
          function()
            builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({ previewer = false }))
          end,
          desc = "Fuzzy find in buffer",
        },

        -- file
        -- stylua: ignore start
        { "<leader>ff", builtin.find_files, desc = "Find file (cwd)" },
        { "<leader>fF", function() builtin.find_files({ cwd = utils.buffer_dir() }) end, desc = "Find file (buffer dir)" },
        { "<leader>fc", function() builtin.find_files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find config" },
        { "<leader>f.", builtin.oldfiles, desc = "Find recent files" },

        -- search text
        { "<leader>jj", builtin.live_grep, desc = "Search grep (cwd)" },
        { "<leader>jg", function() builtin.live_grep( {cwd = utils.buffer_dir()}) end, desc = "Search grep (buffer dir)" },
        { "<leader>jf", function() builtin.live_grep( {grep_open_files = true}) end, desc = "Search grep (current files)" },
        { "<leader>jw", builtin.grep_string, desc = "Grep by current word (cwd)" },
        { "<leader>jW", function() builtin.grep_string({ cwd = utils.buffer_dir() }) end, desc = "Grep by current word (buffer dir)" },
        { "<leader>jb", builtin.current_buffer_fuzzy_find, desc = "Search in buffer (fuzzy)" },

        -- search
        { '<leader>s"', builtin.registers, desc = "Search registers (<C-e> to edit)" },
        { "<leader>sa", builtin.autocommands, desc = "Search autoommands" },
        { "<leader>st", builtin.builtin, desc = "Search Telescope builtins" },
        { "<leader>sr", builtin.resume, desc = "Resume last search" },
        { "<leader>sh", builtin.help_tags, desc = "Search Help" },
        { "<leader>sc", builtin.command_history, desc = "Search command history" },
        { "<leader>sC", builtin.commands, desc = "Search commands" },
        { "<leader>sk", builtin.keymaps, desc = "Search keymaps" },
        { "<leader>sm", builtin.marks, desc = "Search marks" },
        { "<leader>so", builtin.vim_options, desc = "Search options" },
        { "<leader>sz", function() builtin.colorscheme({ enable_preview = true }) end, desc = "Pick colorscheme" },

        -- LSP
        { "<leader>lsd", function() builtin.diagnostics({ bufnr = 0 }) end, desc = "Search diagnostics" },
        { "<leader>lsf", builtin.diagnostics, desc = "Search workspace diagnostics" },

        -- stylua: ignore end
      }
    end,
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
          mappings = {
            i = {
              ["<Tab>"] = actions.move_selection_worse,
              ["<S-Tab>"] = actions.move_selection_better,
            },
            n = {
              ["<Tab>"] = actions.move_selection_worse,
              ["<S-Tab>"] = actions.move_selection_better,
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
