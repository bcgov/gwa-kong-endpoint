package = "gwa-kong-endpoint"
version = "VERSION"
supported_platforms = {"linux", "macosx"}
source = {
  url = "git://github.com/GITHUB_PROJECT.git",
  tag = "VERSION"
}
description = {
  summary = "BC Government GWA Plugin",
  license = "Apache-2.0"
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.bcgov-gwa-endpoint.migrations.init"] = "kong/plugins/bcgov-gwa-endpoint/migrations/init.lua",
    ["kong.plugins.bcgov-gwa-endpoint.migrations.postgres_001"] = "kong/plugins/bcgov-gwa-endpoint/migrations/postgres_001.lua",
    ["kong.plugins.bcgov-gwa-endpoint.access"] = "kong/plugins/bcgov-gwa-endpoint/access.lua",
    ["kong.plugins.bcgov-gwa-endpoint.api"] = "kong/plugins/bcgov-gwa-endpoint/api.lua",
    ["kong.plugins.bcgov-gwa-endpoint.daos"] = "kong/plugins/bcgov-gwa-endpoint/daos.lua",
    ["kong.plugins.bcgov-gwa-endpoint.handler"] = "kong/plugins/bcgov-gwa-endpoint/handler.lua",
    ["kong.plugins.bcgov-gwa-endpoint.schema"] = "kong/plugins/bcgov-gwa-endpoint/schema.lua",
  }
}
