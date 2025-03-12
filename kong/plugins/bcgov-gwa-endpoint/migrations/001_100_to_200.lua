return {
  postgres = {
    up = function(connector, _)
      local rows, err = connector:query("SELECT distinct group FROM acls")
      if err then
        return err
      else        
        local group_map = {
          gwa_admin = { group = 'gwa_admin' },
          gwa_api_owner = { group = 'gwa_api_owner' }
        }
        for _, row in ipairs(rows) do
          if not group_map[row.group] then
            group_map[row.group] = { group = row.group }
          end
        end
        
        local group_names = {}
        for group_name in pairs(group_map) do table.insert(group_names, group_name) end
        
        for i, group_name in ipairs(group_names) do
          local group = group_map[group_name]
          local query = string.format(
            "INSERT INTO group_names (id, \"group\") VALUES (gen_random_uuid(), '%s') ON CONFLICT (\"group\") DO NOTHING",
            group.group
          )
          local _, err = connector:query(query)
          if err then
            return err
          end
        end
      end
    end,
    teardown = function()
    end
  },
}