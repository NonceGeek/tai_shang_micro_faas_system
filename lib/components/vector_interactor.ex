defmodule Components.VectorInteractor do
    @moduledoc """
        interactor with embedbase framework and other datasets.
    """

    defp key() do
        Constants.get_embedbase_key()
    end

    def insert_data(dataset_id, data) do
        EmbedbaseEx.insert_data(dataset_id, data, key())
    end

    def insert_data(dataset_id, data, meta_data) do
        EmbedbaseEx.insert_data(dataset_id, data, meta_data, key())
    end 

    def update_data(dataset_id, data, id) do
        EmbedbaseEx.update_data(dataset_id, data, id, key())
    end

    def search_data(dataset_id, question) do
        EmbedbaseEx.search_data(dataset_id, question, key())
    end

    def delete_data(dataset_id, ids) do
        EmbedbaseEx.delete_data(dataset_id, ids, key())
    end

    def delete_dataset(dataset_id) do
        EmbedbaseEx.delete_dataset(dataset_id, key())
    end

end
  