defmodule Ryujin.Repo.Migrations.EnablePostgresAge do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS age;")
    execute("LOAD 'age';")

    execute("""
    DO $$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM ag_catalog.ag_graph WHERE name = 'ryujin_graph') THEN
        PERFORM ag_catalog.create_graph('ryujin_graph');
      END IF;
    END
    $$;
    """)
  end

  def down do
    execute("""
    DO $$
    BEGIN
      IF EXISTS (SELECT 1 FROM ag_catalog.ag_graph WHERE name = 'ryujin_graph') THEN
        PERFORM ag_catalog.drop_graph('ryujin_graph', true);
      END IF;
    END
    $$;
    """)
    execute("DROP EXTENSION IF EXISTS age CASCADE;")
  end
end
