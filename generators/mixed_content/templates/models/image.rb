class Image < ActiveRecord::Base
  
  def name; title end
  
  acts_as_mixed_content
  belongs_to :image_asset, :foreign_key => 'asset_id'
  
  validates_length_of :copyright, :maximum => 60
  validates_length_of :caption, :maximum => 500
  
  # validates_presence_of :static_image_asset validates_presence_of asset_id does the same thing
  
  # asset_id gets un-set but asset does not because form has a hidden_input called asset_id...
  validates_presence_of :asset_id
  validates_associated :image_asset
  
  validates_length_of :title, :maximum => 255
  
  def get_search_text
    caption
  end  
end
