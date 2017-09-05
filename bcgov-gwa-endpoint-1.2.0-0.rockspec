package = "bcgov-gwa-endpoint"
version = "1.2.0-0"
source = {
  url = "https://gogs.data.gov.bc.ca/DataBC/kong-bcgov-gwa-endpoint",
  tag = "1.2.0"
}
description = {
  summary = "BC Government GWA Plugin",
  license = "UNLICENSED"
}
dependencies = {
  "lua ~> 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.bcgov-gwa-endpoint.migrations.cassandra"] = "kong/plugins/bcgov-gwa-endpoint/migrations/cassandra.lua",
    ["kong.plugins.bcgov-gwa-endpoint.migrations.postgres"] = "kong/plugins/bcgov-gwa-endpoint/migrations/postgres.lua",
    ["kong.plugins.bcgov-gwa-endpoint.access"] = "kong/plugins/bcgov-gwa-endpoint/access.lua",
    ["kong.plugins.bcgov-gwa-endpoint.api"] = "kong/plugins/bcgov-gwa-endpoint/api.lua",
    ["kong.plugins.bcgov-gwa-endpoint.daos"] = "kong/plugins/bcgov-gwa-endpoint/daos.lua",
    ["kong.plugins.bcgov-gwa-endpoint.handler"] = "kong/plugins/bcgov-gwa-endpoint/handler.lua",
    ["kong.plugins.bcgov-gwa-endpoint.schema"] = "kong/plugins/bcgov-gwa-endpoint/schema.lua",
  }
}
