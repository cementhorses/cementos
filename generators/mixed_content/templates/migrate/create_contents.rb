class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.integer   :item_id
      t.string    :item_type
      t.integer   :position
      t.integer   :container_id
      t.string    :container_type
      t.text      :item_search_text

      t.timestamps
    end
  end

  def self.down
    drop_table :contents
  end
end