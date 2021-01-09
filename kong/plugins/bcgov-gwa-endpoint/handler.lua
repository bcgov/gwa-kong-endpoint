local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.bcgov-gwa-endpoint.access"
local cache = kong.cache

local BcGovGwaHandler = BasePlugin:extend()

function BcGovGwaHandler:new()
  BcGovGwaHandler.super.new(self, "bcgov-gwa-endpoint")
end

function BcGovGwaHandler:init_worker()
  local worker_events = kong.worker_events
  worker_events.register(function(data)
    if data.operation == "delete" then
      local new = data.entity
      cache:invalidate("consumerCustomId."..new.custom_id)
      cache:invalidate("consumerUsername."..new.username)
    elseif data.operation == "update" then
      local old = data.old_entity
      cache:invalidate("consumerCustomId."..old.custom_id)
      cache:invalidate("consumerUsername."..old.username)
    end
  end, "crud", "consumers")

  worker_events.register(function(data)
    local new = data.entity
    if data.operation == "delete" then
      local cacheKey = "consumerGroup."..new.consumer.id..new.group
      -- Don't fail if cache clearing fails
      pcall(function()
        cache:invalidate(cacheKey)
      end)
    elseif data.operation == "update" then
      local old = data.old_entity
      cache:invalidate("consumerGroup."..old.consumer.id..old.group)
      kong.db.group_names:insert({group = new.group})
    elseif data.operation == "create" then
      kong.db.group_names:insert({group = new.group})
    end
  end, "crud", "acls")
end

function BcGovGwaHandler:access(conf)
  BcGovGwaHandler.super.access(self)
  access.execute(conf)
end

BcGovGwaHandler.PRIORITY = 1000

return BcGovGwaHandler
