local typedefs = require "kong.db.schema.typedefs"

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
            unique    = true,
          },
        },
      },
    },
}
