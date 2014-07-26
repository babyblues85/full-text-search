class ChangeStemsArrayToString < ActiveRecord::Migration
  def change
    add_column :stems, :word, :string
    remove_column :stems, :stems
  end
end
