local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.bcgov-gwa-endpoint.access"

local BcGovGwaHandler = BasePlugin:extend()

function BcGovGwaHandler:new()
  BcGovGwaHandler.super.new(self, "bcgov-gwa-endpoint")
end


function BcGovGwaHandler:access(conf)
  BcGovGwaHandler.super.access(self)
  access.execute(conf)
end

BcGovGwaHandler.PRIORITY = 1000

return BcGovGwaHandler
