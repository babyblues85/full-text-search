class AddStringArrayForStems < ActiveRecord::Migration
  def change
    add_column :search_documents, :stems, :string, array: true, default: []
    add_index  :search_documents, :stems, using: 'gin'
  end
end
