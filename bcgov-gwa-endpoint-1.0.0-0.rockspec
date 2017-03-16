package = "bcgov-gwa-endpoint"
version = "1.0.0-0"
supported_platforms = {"linux", "macosx"}
source = {
  url = "https://gogs.data.gov.bc.ca/DataBC/gwa/src/master/kong/plugins/bcgov-gwa-endpoint",
  tag = "1.0.0"
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
    ["kong.plugins.bcgov-gwa-endpoint.handler"] = "kong/plugins/bcgov-gwa-endpoint/handler.lua",
    ["kong.plugins.bcgov-gwa-endpoint.schema"] = "kong/plugins/bcgov-gwa-endpoint/schema.lua",
  }
}
