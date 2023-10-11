local app_helpers = require "lapis.application"

return {
  postgres = {
    up = [[
      CREATE TABLE IF NOT EXISTS group_names(
        id uuid,
        "group" text,
        created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
        PRIMARY KEY (id),
        CONSTRAINT group_names_group_key UNIQUE("group")
      );

      DO $$
      BEGIN
        IF (SELECT to_regclass('group_names_group')) IS NULL THEN
          CREATE INDEX group_names_group ON group_names("group");
        END IF;
      END$$;
    ]],
    teardown = function()
    end
  },
}