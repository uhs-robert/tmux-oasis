return {
  {
    "banner-plugin",
    lazy = false,
    config = function()
      local banner = require("plugins.banner").get_random_banner()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          for _, line in ipairs(banner) do
            print(line)
          end
        end,
      })
    end,
  },
}

