class RenameSearchDocumentToStems < ActiveRecord::Migration
  def change
    rename_table :search_documents, :stems
  end
end
