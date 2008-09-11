class DownloadAsset < Asset
  
  has_attachment :content_type => ['application/pdf', 'application/zip', 'application/x-zip-compressed', 'application/x-zip', 'application/x-compress', 'application/x-compressed', 'multipart/x-zip', 'application/octet-stream'], 
                 :storage => :file_system, 
                 :path_prefix => 'public/system/download',
                 :max_size => 50.megabytes,
               :processor => :Rmagick
               
  validates_attachment :content_type => 'The file must be a .pdf or .zip'
  
end
