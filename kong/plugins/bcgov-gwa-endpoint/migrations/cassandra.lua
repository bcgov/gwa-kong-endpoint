local singletons = require "kong.singletons"

return {
  {
    name = "2018-09-28_init_group_names",
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
    name = "2018-09-28_init_group_names_data",
    up = function(db, _, dao)
      local rows, err = db:query("SELECT group FROM acls")
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
        group_names = {}
        for group_name in pairs(group_map) do table.insert(group_names, group_name) end
        for i,group_name in ipairs(group_names) do
          local group = group_map[group_name];
          dao.group_names:insert(group)
        end
      end
    end,
    down = function()
    end
  }
}
