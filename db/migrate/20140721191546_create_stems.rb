class CreateStems < ActiveRecord::Migration
  def change
    create_table :stems do |t|
      t.references :searchable, polymorphic: true
      t.string :word
      
      t.timestamps
    end
  end
end
