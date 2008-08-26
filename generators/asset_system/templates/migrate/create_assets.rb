class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.integer :asset_parent_id, :parent_id, :size, :width, :height
      t.string :asset_parent_type, :type, :filename, :content_type, :thumbnail
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
