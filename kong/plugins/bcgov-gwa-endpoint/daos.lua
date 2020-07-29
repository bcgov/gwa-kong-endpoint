local singletons = require "kong.singletons"
local typedefs = require "kong.db.schema.typedefs"

local function check_unique(group, group_name)
  if singletons.dao and group then
    local res, err = singletons.dao.group_names:find_all {group = group}
    if not err and #res > 0 then
      return false, "group already exists"
    elseif not err then
      return true
    end
  end
end

return {
    -- this plugin only results in one custom DAO, named `keyauth_credentials`:
    group_names = {
      name               = "group_names", -- the actual table in the database
      endpoint_key       = "group",
      primary_key        = { "id" },
      cache_key          = { "group" },
      generate_admin_api = true,
      fields = {
        {
          -- a value to be inserted by the DAO itself
          -- (think of serial id and the uniqueness of such required here)
          id = typedefs.uuid,
        },
        {
          -- also interted by the DAO itself
          created_at = typedefs.auto_timestamp_s,
        },
        {
          -- a unique Group
          group = {
            type      = "string",
            required  = true,
            unique    = true
          },
        },
      },
    },
  }

-- local SCHEMA = {
--   primary_key = {"id"},
--   table = "group_names",
--   fields = {
--     id = { type = "id", dao_insert_value = true },
--     created_at = { type = "timestamp", dao_insert_value = true },
--     group = { type = "string", required = true, func = check_unique }
--   },
--   marshall_event = function(self, t)
--     return {id = t.id}
--   end
-- }

-- return {group_names = SCHEMA}
