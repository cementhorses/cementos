class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string   "title"
      t.text     "caption"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "float"
      t.integer  "image_id"
      t.integer  "asset_id"
      t.string   "size", :default => "small", :null => false
      t.text     "copyright"
      
      t.timestamps
    end
  end

  def self.down
    drop_table :static_images
  end
end
