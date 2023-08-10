-- CeoInvite
-- Adds an "Invite to CEO/MC" option in the Players menu
-- https://github.com/hexarobi/stand-lua-ceoinvite

local SCRIPT_VERSION = "0.1"

-- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
local status, auto_updater = pcall(require, "auto-updater")
if not status then
    local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
    async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
            function(result, headers, status_code)
                local function parse_auto_update_result(result, headers, status_code)
                    local error_prefix = "Error downloading auto-updater: "
                    if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                    if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                    filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                    local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                    if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                    file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
                end
                auto_update_complete = parse_auto_update_result(result, headers, status_code)
            end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
    async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
    if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
    auto_updater = require("auto-updater")
end
if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

auto_updater.run_auto_update({
    source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-ceoinvite/main/CeoInvite.lua",
    script_relpath=SCRIPT_RELPATH,
    verify_file_begins_with="--",
})


players.add_command_hook(function(player_id)
    menu.divider(menu.player_root(player_id), "My Menu")

    local join_org_command = menu.ref_by_rel_path(menu.player_root(player_id), "Join CEO/MC")
    if not menu.is_ref_valid(join_org_command) then
        error("Could not find `Join CEO/MC` menu item for player")
    end

    local invite_org_command = menu.shadow_root():action("Invite to CEO/MC", {"ceoinvite"}, "Invite player to your current organization (SecuroServ CEO or Motorcycle Club)", function()
        if players.get_org_type(players.user()) == -1 then
            util.toast("Cannot send invite until create an organization (ServoServ CEO or Motorcycle Club")
            return
        end

        -- Thanks to Totaw Annihiwation for this script event!
        util.trigger_script_event(1 << player_id, {
            -245642440,
            players.user(),
            4,
            10000, -- wage?
            0,
            0,
            0,
            0,
            memory.read_int(memory.script_global(1924276 + 9)), -- f_8
            memory.read_int(memory.script_global(1924276 + 10)), -- f_9
        })
    end, nil, nil, COMMANDPERM_FRIENDLY)

    menu.attach_after(join_org_command, invite_org_command)
end)

menu.my_root():readonly("Version", SCRIPT_VERSION)
menu.my_root():readonly("New player menu options now available", "While this script is running, an additional menu item is available within the Players menu.")
--menu.my_root():action("Players Menu", {}, "", function()
--    menu.ref_by_path("Players>Settings"):focus()
--end)
