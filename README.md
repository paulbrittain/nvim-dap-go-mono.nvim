# nvim-dap-go-mono.nvim

A Neovim plugin for debugging Go microservices.

## Description

This plugin extends the functionality of nvim-dap for Go, specifically tailored for debugging microservices in a mono repository

## Installation

Using lazy.nvim:

```lua
return {
    "leoluz/nvim-dap-go",
    event = 'VeryLazy',
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",  -- required by Telescope
        "paulbrittain/nvim-dap-go-mono.nvim",
    },
    config = function()
        local dap_go_service_debug = require("nvim-dap-go-mono")

        dap_go_service_debug.setup({
            services = {
                { name = "exampleService1", port = 1 },
                { name = "exampleService2", port = 2 },
            },
            substitution_path = "${workspaceFolder}/services",
            remote_path_prefix = "app/"
        })

        require("dap-go").setup({
            dap_configurations = dap_go_service_debug.generate_debug_dap_configurations(),
            delve = {
                port = "${port}",
            },
        })

        -- optional, mostly for myself. You can use nvim-dap-go's picker.
        vim.keymap.set("n", "<leader>ds", dap_go_service_debug.debug_service_picker, { desc = "Debug Service Picker" })

    end,
}
```
