local M = {}

M.config = {
    services = {},
    substitution_path = "${workspaceFolder}",
    remote_path_prefix = "",
}

local function get_debug_config(service_name, port)
    return {
        type = "go",
        name = service_name,
        request = "attach",
        mode = "remote",
        substitutePath = {
            {
                from = M.config.substitution_path .. service_name:lower(),
                to = M.config.remote_path_prefix .. service_name:lower(),
            },
        },
        port = port,
    }
end

function M.setup(opts)
    if type(opts) ~= "table" then
        error("Setup options must be a table")
    end
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.generate_debug_dap_configurations()
    if not M.config.services or #M.config.services == 0 then
        print("No services configured")
        return {}
    end
    local dap_configurations = {}
    for _, service in ipairs(M.config.services) do
        table.insert(dap_configurations, get_debug_config(service.name, service.port))
    end
    return dap_configurations
end

local function debug_service(service_name)
    local dap_configurations = M.generate_debug_dap_configurations()
    for _, config in ipairs(dap_configurations) do
        if config.name:lower() == service_name:lower() then
            require("dap").run(config)
            return
        end
    end
    print("Service not found: " .. service_name)
end

-- Just for fun, I've included my own telescope picker. The user can choose to use the nvim-dap-go picker, though.
function M.debug_service_picker()
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local config = require('telescope.config').values

    pickers.new({}, {
        prompt_title = "Debug Service",
        finder = finders.new_table {
            results = M.config.services,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.name .. " " .. "(Port: " .. entry.port .. ")",
                    ordinal = entry.name,
                }
            end,
        },
        sorter = config.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                print("Selected service: " .. selection.value.name .. " on port " .. selection.value.port)
                debug_service(selection.value.name)
            end)
            return true
        end,
    }):find()
end

return M
