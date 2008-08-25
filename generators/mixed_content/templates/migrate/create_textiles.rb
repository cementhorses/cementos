class CreateTextiles < ActiveRecord::Migration
  def self.up
    create_table :textiles do |t|
      t.text :textile
      t.text :cached_html
      t.timestamps
    end
  end

  def self.down
    drop_table :textiles
  end
end