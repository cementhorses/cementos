class Asset < ActiveRecord::Base

  # subclass this model to create attachment_fu file and image models

  # this method is used by asset uploaders
  def thumb
    self.thumbnails.detect{|x| x.thumbnail == 'thumb'}
  end
  
end
