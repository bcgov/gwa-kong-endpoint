local cjson = require "cjson"
--local crud = require "kong.api.crud_helpers"
local endpoints = require "kong.api.endpoints"
local singletons = require "kong.singletons"
--local responses = require "kong.tools.responses"
local groups_schema = kong.db.group_names.schema
local acls_schema = kong.db.acls.schema
local escape_uri   = ngx.escape_uri
local unescape_uri = ngx.unescape_uri
local type         = type
local fmt          = string.format
local select       = select
local tostring     = tostring
local concat       = table.concat

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
    GET = endpoints.get_collection_endpoint(
        groups_schema),

    -- PUT = endpoints.put_collection_endpoint(
    --     groups_schema),
    
    POST = endpoints.post_collection_endpoint(
        groups_schema),
    -- PUT = function(self, dao_factory)
    --   crud.put(self.params, dao_factory.group_names)
    -- end,

    -- POST = function(self, dao_factory)
    --   crud.post(self.params, dao_factory.group_names)
    -- end
  },

--   ["/groups/:group_or_id"] = {
--     before = function(self, dao_factory, helpers)
--        local group_names, err = crud.find_by_id_or_field(
--         dao_factory.group_names,
--         { },
--         self.params.group_or_id,
--         "group"
--       )

--       if err then
--         return helpers.yield_error(err)
--       elseif #group_names == 0 then
--         return helpers.responses.send_HTTP_NOT_FOUND()
--       end
--       self.params.group_or_id = nil

--       self.group_name = group_names[1]
--     end,

--     GET = function(self, dao_factory, helpers)
--       return helpers.responses.send_HTTP_OK(self.group_name)
--     end,

--     PATCH = function(self, dao_factory)
--       crud.patch(self.params, dao_factory.group_names, self.group_name)
--     end,

--     DELETE = function(self, dao_factory)
--       local group = self.group_name.group
--       local acls, err = singletons.dao.acls:find_all({group = group})
--       if err then
--       else
--         local acl_ids = {}
--         for i, acl in ipairs(acls) do
--           if acl.id then
--             acl_ids[i] = {id = acl.id}
--           end
--         end
--         for i, acl in ipairs(acl_ids) do
--           local _,err2 = singletons.dao.acls:delete(acl)
--         end
--       end
--       crud.delete(self.group_name, dao_factory.group_names)
--     end
--   },


  ["/groups/:group/consumers"] = {
    schema = acls_schema,
    GET = function(self, db, helpers)
            local schema = acls_schema
            local next_page_tags = ""
            local dao = db[schema.name]

            local options = {
                nulls = true,
                pagination = {
                  page_size     = 100,
                  max_page_size = 1000,
                },
                group = self.params.group
            }

            local args = self.args.uri
            if args.tags then
                next_page_tags = "&tags=" .. (type(args.tags) == "table" and args.tags[1] or args.tags)
            end
        
            next_page_tags = "&group=" .. self.params.group

            kong.log.err(next_page_tags)
            local data, _, err_t, offset = dao["page"](dao, 100, ngx.null, opts)
            if err_t then
                return endpoints.handle_error(err_t)
            end
        
            local next_page = offset and fmt("/%s?%s",
                                            schema.admin_api_name or
                                            schema.name,
                                            next_page_tags) or null
        
            return ok {
                data   = data,
                offset = offset,
                next   = next_page,
            }
    end
  }
}
