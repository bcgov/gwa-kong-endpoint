local typedefs = require "kong.db.schema.typedefs"

return {
  name = "bcgov-gwa-endpoint",
  fields = {
    {
      consumer = typedefs.no_consumer
    },
    {
      config = {
        type = "record",
        fields = {
          {
            api_owners = {
              type = "array",
              elements = { type = "string" },
            }
          },
        },
      },
    },
  },
}
