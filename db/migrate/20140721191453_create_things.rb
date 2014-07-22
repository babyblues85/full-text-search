class CreateThings < ActiveRecord::Migration
  def change
    create_table :things do |t|
      t.text :content
      t.timestamps
    end
  end
end
