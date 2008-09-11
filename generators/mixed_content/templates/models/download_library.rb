class DownloadLibrary < ActiveRecord::Base
  acts_as_mixed_content
  
  # TODO: move sub_item association code to plugin
   has_many :downloads, :order => "position" do
     def update_from_params(params_hash = {})
       params_hash.each do |sub_item_id, sub_item_fields|
         if sub_item = proxy_owner.downloads.detect{|i| i.id == sub_item_id.to_i} # update content if already attached to this container
           sub_item.attributes = sub_item_fields
         else # otherwise create sub_item on model
           build(sub_item_fields)
         end
       end
       proxy_owner.downloads.sort!{|x,y| x.position.to_i <=> y.position.to_i}
     end
   end

   alias_method :pre_mixed_content_downloads=, :downloads=
   
   validates_size_of :downloads, :minimum => 1, :message => "must contain at least one download"
   validate :downloads_should_have_an_asset

   after_update :save_downloads

   def validate
     downloads.select{|c| !c.to_be_destroyed}.each do |download|
       errors.add_to_base "Downloads contain errors" unless download.valid?
     end
   end

   # intercept a hash
   def downloads=(s)
     if s.is_a?(Hash)
       downloads.update_from_params(s)
     else
       pre_mixed_content_downloads=(s)
     end
   end

   # need this to preserve order fields
   def save_downloads
     self.downloads.each do |s|
       if s.to_be_destroyed
         s.destroy #TODO: make this handle dependent destroy?
       else
         s.save!
       end
     end
   end

   def get_search_text
     search_text = ""
     self.downloads.each { |d| search_text += "#{d.caption} " }
     search_text
   end

  def downloads_should_have_an_asset
    self.errors.add(:download, "must have an downloadable file") if !downloads.each { |d| break(false) if d.asset_id.nil? }
  end

   # TODO: move to plugin
   # return the actual id if it exists, otherwise make up a random id starting with a letter
   def temporary_id
     @temporary_id ||= id || "t#{self.__id__}"
   end
end