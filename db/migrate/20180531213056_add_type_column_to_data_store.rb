class AddTypeColumnToDataStore < ActiveRecord::Migration[5.2]
  def change
    add_column :data_stores, :type, :string, index: true
  end
end
