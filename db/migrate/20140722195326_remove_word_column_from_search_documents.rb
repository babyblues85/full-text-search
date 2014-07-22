class RemoveWordColumnFromSearchDocuments < ActiveRecord::Migration
  def change
    remove_column :search_documents, :word
  end
end
