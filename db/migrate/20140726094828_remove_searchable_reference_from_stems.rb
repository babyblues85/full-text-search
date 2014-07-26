class RemoveSearchableReferenceFromStems < ActiveRecord::Migration
  def change
    remove_column :stems, :searchable_id
    remove_column :stems, :searchable_type
  end
end
