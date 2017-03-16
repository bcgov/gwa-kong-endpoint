local BasePlugin = require "kong.plugins.base_plugin"
local utils = require "kong.tools.utils"
local cache = require "kong.tools.database_cache"
local singletons = require "kong.singletons"
local constants = require "kong.constants"
local responses = require "kong.tools.responses"

local BcGovGwaHandler = BasePlugin:extend()

function BcGovGwaHandler:new()
  BcGovGwaHandler.super.new(self, "bcgov-gwa-endpoint")
end

function BcGovGwaHandler:access(conf)
  BcGovGwaHandler.super.access(self)
end

BcGovGwaHandler.PRIORITY = 1

return BcGovGwaHandler
