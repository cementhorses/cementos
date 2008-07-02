class CreateCementosPages < ActiveRecord::Migration
  def self.up
    create_table "pages" do |t|
      t.string   "name"
      t.string   "path"
      t.string   "slug"
      t.string   "template",              :default => 'generic'
      t.integer  "parent_id"
      t.integer  "position",              :default => 0,     :null => false
      t.integer  "lock_version",          :default => 0,     :null => false
      t.string   "immutable_name"
      t.boolean  "display_in_navigation", :default => true,  :null => false
      t.string   "frame"
      t.text     "description"
      t.text     "keywords"
      t.boolean  "published",             :default => true,  :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :pages
  end
end