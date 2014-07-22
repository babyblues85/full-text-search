class AddIndexForSearchableType < ActiveRecord::Migration
  def change
    add_index :search_documents, :searchable_type
  end
end
