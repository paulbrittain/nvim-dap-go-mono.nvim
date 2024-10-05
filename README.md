<h1 align="center">nvim-dap-go-mono.nvim</h1>

This plugin extends the functionality of [nvim-dap-go](https://github.com/leoluz/nvim-dap-go) specifically tailored for debugging microservices in a mono repository, the way I want it.

The project structure that this plugin is useful for looks like the following example. Note that you can specify your own substitution_path and remote_path_prefix to adjust to your own mono-repositories strucure and container path.

```
my-project/
├── go.mod
├── go.sum
└── services/
    ├── service1/
    │   ├── main.go
    │   ├── go.mod
    │   └── go.sum
    └── service2/
        ├── main.go
        ├── go.mod
        └── go.sum
```

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
            substitution_path = "${workspaceFolder}/services/",
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
