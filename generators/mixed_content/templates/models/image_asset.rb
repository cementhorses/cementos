class ImageAsset < Asset
    
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :path_prefix => 'public/system/assets/images',
                 :max_size => 500.kilobytes,
                 :thumbnails => { 
                   :thumb => '100x100!', 
                   :small => '186x', 
                   :large => '396x'
                 },
                 :processor => :Rmagick

  # validates_attachment :content_type => 'This file is not a JPEG, PNG or GIF.'
  
end