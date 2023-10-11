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
            }
          },
        },
      },
    },
  },
}
