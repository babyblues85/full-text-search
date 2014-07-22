class RenameStemsToSearchDocuments < ActiveRecord::Migration
  def change
    rename_table :stems, :search_documents
  end
end
