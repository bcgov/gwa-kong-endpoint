local kong = kong

local BcGovGwaHandler = {
  VERSION  = "2.0.0",
  PRIORITY = 1000,
}

local access = require "kong.plugins.bcgov-gwa-endpoint.access"

local function insert_if_missing(group)
    kong.db.group_names:insert({group = group})
end

function BcGovGwaHandler:init_worker()
  local cache = kong.cache
  local worker_events = kong.worker_events
  
  worker_events.register(function(data)
    if data.operation == "delete" or data.operation == "create" then
      local new = data.entity
      cache:invalidate("consumerCustomId."..new.custom_id)
      cache:invalidate("consumerUsername."..new.username)
    elseif data.operation == "update" then
      local new = data.entity
      local old = data.old_entity
      cache:invalidate("consumerCustomId."..old.custom_id)
      cache:invalidate("consumerUsername."..old.username)
      cache:invalidate("consumerCustomId."..new.custom_id)
      cache:invalidate("consumerUsername."..new.username)
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
      insert_if_missing(new.group)
    elseif data.operation == "create" then
      insert_if_missing(new.group)
    end
  end, "crud", "acls")
end

function BcGovGwaHandler:access(conf)
  -- BcGovGwaHandler.super.access(self) -- Removed super call for Kong 3
  access.execute(conf)
end

return BcGovGwaHandler
