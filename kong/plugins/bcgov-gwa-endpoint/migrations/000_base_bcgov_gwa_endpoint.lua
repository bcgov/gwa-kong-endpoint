return {
  postgres = {
    up = [[
      CREATE TABLE IF NOT EXISTS "group_names" (
        "id" UUID PRIMARY KEY,
        "group" TEXT UNIQUE,
        "created_at" TIMESTAMP WITH TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')
      );

      DO $$
      BEGIN
        IF (SELECT to_regclass('group_names_group_idx')) IS NULL THEN
          CREATE INDEX IF NOT EXISTS "group_names_group_idx" ON "group_names" ("group");
        END IF;
      END$$;
    ]],
  },
}