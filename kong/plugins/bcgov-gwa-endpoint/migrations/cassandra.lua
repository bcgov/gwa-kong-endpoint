return {
  {
    name = "2017-08-31_init_group_names",
    up = [[
      CREATE TABLE IF NOT EXISTS group_names(
        id uuid,
        group text,
        created_at timestamp,
        PRIMARY KEY (id)
      );

      CREATE INDEX IF NOT EXISTS ON group_names(group);
    ]],
    down = [[
      DROP TABLE group_names;
    ]]
  },{
    name = "2017-06-09-31_init_group_names_data",
    up = function(_, _, dao_factory)
      local rows, err = dao_factory.acls:find_all()
      if err then
        return helpers.yield_error(err)
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
        group_names = {}
        for group_name in pairs(group_map) do table.insert(group_names, group_name) end
        for i,group_name in ipairs(group_names) do
          local group = group_map[group_name];
          dao_factory.group_names:insert(group)
        end
      end
    end,
    down = function()
    end
  }
}
