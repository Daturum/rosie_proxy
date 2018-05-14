# This migration comes from rosie (originally 20180426084958)
class AddSizeToRosieAssetFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :rosie_asset_files, :size, :integer
  end
end
