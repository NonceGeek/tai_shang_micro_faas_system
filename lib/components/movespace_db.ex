defmodule Components.MovespaceDB do
    alias TaiShangMicroFaasSystem.Repo
    alias Ecto.Adapters.SQL
    def create_vector_db_if_uncreated(vector_db_name, size \\ 1536) do
        sql_cmd = """
            CREATE TABLE #{vector_db_name} (
                id bigserial PRIMARY KEY, 
                id_in_embedbase text,
                raw_data text,
                meta_data JSONB,
                embedding vector(#{size}));
        """
        SQL.query(Repo, sql_cmd, [])
    end

    def insert_vector(vector_db_name, id_in_embedbase, raw_data, meta_data, embedding) do
        sql_cmd = """
            INSERT INTO #{vector_db_name} (id_in_embedbase, raw_data, meta_data, embedding) VALUES (
                '#{id_in_embedbase}',
                '#{raw_data}',
                '#{data_to_sql_string(meta_data)}',
                '#{data_to_sql_string(embedding)}');
        """
        SQL.query(Repo, sql_cmd, [])
    end

    def data_to_sql_string(nil), do: "null"
    def data_to_sql_string(data), do: Poison.encode!(data)

    def search_data_by_id(vector_db_name, id) do
        sql_cmd = """
            SELECT * FROM #{vector_db_name} WHERE id = '#{id}';
        """
        SQL.query(Repo, sql_cmd, [])
    end

    def search_data_by_indexer_in_embedbase(vector_db_name, id_in_embedbase) do
        sql_cmd = """
            SELECT * FROM #{vector_db_name} WHERE id_in_embedbase = '#{id_in_embedbase}';
        """
        SQL.query(Repo, sql_cmd, [])
    end

end