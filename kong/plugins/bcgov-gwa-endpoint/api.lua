local cjson = require "cjson"
local kong = kong
local groups_schema = kong.db.group_names.schema
local acls_schema = kong.db.acls.schema
local escape_uri = ngx.escape_uri
local unescape_uri = ngx.unescape_uri
local type = type
local fmt = string.format
local select = select
local tostring = tostring
local concat = table.concat

local function get_message(default, ...)
    local message
    local n = select("#", ...)
    if n > 0 then
      if n == 1 then
        local arg = select(1, ...)
        if type(arg) == "table" then
          message = arg
        elseif arg ~= nil then
          message = tostring(arg)
        end
  
      else
        message = {}
        for i = 1, n do
          local arg = select(i, ...)
          message[i] = tostring(arg)
        end
        message = concat(message)
      end
    end
  
    if not message then
      message = default
    end
  
    if type(message) == "string" then
      message = { message = message }
    end
  
    return message
end

local function ok(...)
  return kong.response.exit(200, get_message(nil, ...))
end

return {
  ["/groups"] = {
    schema = groups_schema,
    GET = function(self, db, helpers)
      local entities, next_page, err_t = db.group_names:page()
      if err_t then
        return kong.response.exit(500, { message = err_t.message })
      end
      
      return kong.response.exit(200, {
        data = entities,
        next = next_page,
      })
    end,
    
    POST = function(self, db, helpers)
      local entity, err_t = db.group_names:insert(self.args.post)
      if err_t then
        return kong.response.exit(400, { message = err_t.message })
      end
      
      return kong.response.exit(201, entity)
    end
  },

  ["/groups/:group/consumers"] = {
    schema = acls_schema,
    GET = function(self, db, helpers)
      local group = self.params.group
      local page_size = 100
      
      local entities, next_page, err_t = db.acls:page({
        size = page_size,
        group = group,
      })
      
      if err_t then
        return kong.response.exit(500, { message = err_t.message })
      end
      
      local next_url = nil
      if next_page then
        next_url = fmt("/groups/%s/consumers?page=%s&size=%d", 
                       escape_uri(group),
                       escape_uri(next_page),
                       page_size)
      end
      
      return kong.response.exit(200, {
        data = entities,
        next = next_url,
      })
    end
  }
}
