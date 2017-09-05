local singletons = require "kong.singletons"

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

local SCHEMA = {
  primary_key = {"id"},
  table = "group_names",
  fields = {
    id = { type = "id", dao_insert_value = true },
    created_at = { type = "timestamp", dao_insert_value = true },
    group = { type = "string", required = true, func = check_unique }
  },
  marshall_event = function(self, t)
    return {id = t.id}
  end
}

return {group_names = SCHEMA}
