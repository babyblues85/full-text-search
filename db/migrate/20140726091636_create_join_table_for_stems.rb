class CreateJoinTableForStems < ActiveRecord::Migration
  def change
    create_table :stem_joins do |t|
      t.integer :stem_id
      t.references :searchable, polymorphic: true
      t.timestamps
    end
  end
end
