# This migration comes from rosie (originally 20180425225051)
class CreateRosieAssetFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :rosie_asset_files do |t|
      t.string :filename
      t.string :content_type
      t.binary :file_contents

      t.timestamps
    end
  end
end
