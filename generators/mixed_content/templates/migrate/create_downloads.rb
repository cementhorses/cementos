




class CreateDownloads < ActiveRecord::Migration
  def self.up
    create_table "downloads", :force => true do |t|
      t.integer  "download_library_id"
      t.string   "name"
      t.text     "caption"
      t.integer  "asset_id"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "leading_text"
    end
  end

  def self.down
    drop_table :downloads
  end
end