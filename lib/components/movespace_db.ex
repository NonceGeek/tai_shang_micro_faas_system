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
        IO.puts "tttttt"
        IO.puts raw_data
        sql_cmd = """
            INSERT INTO #{vector_db_name} (id_in_embedbase, raw_data, meta_data, embedding) VALUES (
                '#{id_in_embedbase}',
                '#{handle_raw_data(raw_data)}',
                '#{data_to_sql_string(meta_data)}',
                '#{data_to_sql_string(embedding)}');
        """
        SQL.query(Repo, sql_cmd, [])
    end

    def handle_raw_data(data), do: String.replace(data, "'", "''") #important
    def data_to_sql_string(nil), do: "null"
    def data_to_sql_string(data), do: Poison.encode!(data)

    def fetch_data_by_id(vector_db_name, id) do
        sql_cmd = """
            SELECT * FROM #{vector_db_name} WHERE id = '#{id}';
        """
        SQL.query(Repo, sql_cmd, [])
    end

    def fetch_data_by_id_in_embedbase(vector_db_name, id_in_embedbase) do
        sql_cmd = """
            SELECT * FROM #{vector_db_name} WHERE id_in_embedbase = '#{id_in_embedbase}';
        """
        SQL.query(Repo, sql_cmd, [])
    end

    def get_count(vector_db_name) do
        sql_cmd = """
            SELECT COUNT(*) FROM #{vector_db_name};
        """
        {:ok,
            %Postgrex.Result{rows: [[count]]}} = 
            SQL.query(Repo, sql_cmd, [])
        count
    end

end