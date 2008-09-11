

class CreateDownloadLibraries < ActiveRecord::Migration
  def self.up
    create_table "download_libraries", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "display_as_library", :default => false, :null => false
    end
  end

  def self.down
    drop_table :download_libraries
  end
end