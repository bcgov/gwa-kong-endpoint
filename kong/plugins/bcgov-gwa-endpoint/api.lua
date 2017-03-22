local cjson = require "cjson"
local crud = require "kong.api.crud_helpers"
local responses = require "kong.tools.responses"

return {
  ["/groups"] = {
    GET = function(self, dao_factory)
      local dao = dao_factory.acls;
      local rows, err = dao_factory.acls:find_all()
      if err then
        return helpers.yield_error(err)
      else
        local distinct_groups = {}
        
        local group_map = {}
        for _, row in ipairs(rows) do
          if not group_map[row.group] then
            group_map[row.group] = { group = row.group }
            distinct_groups[#distinct_groups+1] = { group = row.group }
          end
        end
        
        return responses.send_HTTP_OK {
          data = #distinct_groups > 0 and distinct_groups or cjson.empty_array,
          total = #distinct_groups,
        }
        
      end
      
    end,
  },

  ["/groups/:group"] = {
    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.acls)
    end,
  },

}
