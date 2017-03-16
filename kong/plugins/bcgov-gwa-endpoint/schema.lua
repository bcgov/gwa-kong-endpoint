return {
  no_consumer = true,
  fields = {
    name = {
      type = "text",
      required = true
    },
    uri_template = {
      type = "text",
      required = true
    },
    created_by = {
      type = "text",
      required = true
    },
    upstream_url = {
      type = "text"
    },
    upstream_username = {
      type = "text"
    },
    upstream_password = {
      type = "text"
    },
  }
}
