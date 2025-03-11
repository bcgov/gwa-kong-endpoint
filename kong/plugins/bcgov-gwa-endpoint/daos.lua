local typedefs = require "kong.db.schema.typedefs"

return {
  {
    name = "group_names", 
    primary_key = { "id" },
    endpoint_key = "group",
    cache_key = { "group" },
    admin_api_name = "groups", -- used in the Admin API endpoint path
    admin_api_nested_name = "group",
    db_export = true,
    
    fields = {
      { id = typedefs.uuid },
      { created_at = typedefs.auto_timestamp_s },
      { group = { type = "string", required = true, unique = true } },
    },
  },
}
