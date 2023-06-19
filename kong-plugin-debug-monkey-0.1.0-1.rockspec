local plugin_name = "debug-monkey"
local package_name = "kong-plugin-" .. plugin_name
local package_version = "0.1.0"
local rockspec_revision = "1"

local github_account_name = "mercedes-benz"
local github_repo_name = "debug-monkey"
local git_checkout = package_version == "main" or package_version


package = package_name
version = package_version .. "-" .. rockspec_revision
supported_platforms = { "linux", "macosx" }
source = {
  url = "git+https://github.com/"..github_account_name.."/"..github_repo_name..".git",
  branch = git_checkout,
}


description = {
  summary = "A Kong plugin to integrate the EmmyLua debugger",
  homepage = "https://github.com/"..github_account_name.."/"..github_repo_name,
  license = "MIT",
}


dependencies = {
}


build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..plugin_name..".handler"] = "kong/plugins/"..plugin_name.."/handler.lua",
    ["kong.plugins."..plugin_name..".schema"] = "kong/plugins/"..plugin_name.."/schema.lua",
  }
}
