local cjson = require "cjson"
local crud = require "kong.api.crud_helpers"
local singletons = require "kong.singletons"
local responses = require "kong.tools.responses"

return {
  ["/groups"] = {
    GET = function(self, dao_factory)        
      crud.paginated_set(self, dao_factory.group_names)
    end,

    PUT = function(self, dao_factory)
      crud.put(self.params, dao_factory.group_names)
    end,

    POST = function(self, dao_factory)
      crud.post(self.params, dao_factory.group_names)
    end
  },

  ["/groups/:group_or_id"] = {
    before = function(self, dao_factory, helpers)
       local group_names, err = crud.find_by_id_or_field(
        dao_factory.group_names,
        { },
        self.params.group_or_id,
        "group"
      )

      if err then
        return helpers.yield_error(err)
      elseif #group_names == 0 then
        return helpers.responses.send_HTTP_NOT_FOUND()
      end
      self.params.group_or_id = nil

      self.group_name = group_names[1]
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.group_name)
    end,

    PATCH = function(self, dao_factory)
      crud.patch(self.params, dao_factory.group_names, self.group_name)
    end,

    DELETE = function(self, dao_factory)
      local group = self.group_name.group
      local acls, err = singletons.dao.acls:find_all({group = group})
      if err then
      else
        local acl_ids = {}
        for i, acl in ipairs(acls) do
          if acl.id then
            acl_ids[i] = {id = acl.id}
          end
        end
        for i, acl in ipairs(acl_ids) do
          local _,err2 = singletons.dao.acls:delete(acl)
        end
      end
      crud.delete(self.group_name, dao_factory.group_names)
    end
  },

  ["/groups/:group/users"] = {
    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.acls)
    end,
  },

}
