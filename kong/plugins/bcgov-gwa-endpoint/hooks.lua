local events = require "kong.core.events"
local cache = require "kong.tools.database_cache"

local function invalidate_on_update(message_t)
  local old = message_t.old_entity
  if message_t.collection == "consumers" then
    cache.delete("consumerCustomId."..old.custom_id)
    cache.delete("consumerUsername."..old.username)
  elseif message_t.collection == "acls" then
    if old.group then
      cache.delete("consumerGroup."..old.consumer_id..old.group)
    end
  end
end

local function invalidate_on_delete(message_t)
  local new = message_t.entity
  if message_t.collection == "consumers" then
    cache.delete("consumerCustomId."..new.custom_id)
    cache.delete("consumerUsername."..new.username)
  elseif message_t.collection == "acls" then
    if new.group then
      cache.delete("consumerGroup."..new.consumer_id..new.group)
    end
  end
end

return {
  [events.TYPES.ENTITY_UPDATED] = function(message_t)
    invalidate_on_update(message_t)
  end,
  [events.TYPES.ENTITY_DELETED] = function(message_t)
    invalidate_on_delete(message_t)
  end
}