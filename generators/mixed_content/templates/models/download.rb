class Download < ActiveRecord::Base
  
  belongs_to :download_library
  belongs_to :download_asset, :foreign_key => 'asset_id'
  
  acts_as_list :scope => :download_library_id
  
  validates_presence_of :asset_id
  # validates_presence_of :download_asset
  

  
  # TODO: move to plugin
  # return the actual id if it exists, otherwise make up a random id starting with a letter
  def temporary_id
    @temporary_id ||= id || "t#{self.__id__}"
  end
  
  attr_accessor :to_be_destroyed
  
end
