# ALLOWED_TYPES = %w(StaticImage Textile) unless defined? ALLOWED_TYPES
# ALLOWED_TYPES.each do |type|
#   class_eval <<-"end_eval"
#     def create_#{type.underscore}(attributes = {})
#       self.item_type = #{type}
#       self.item      = #{type}.create(attributes)
#       self.save
#     end
#     
#     def #{type.underscore}
#       item.kind_of? #{type} ? item : nil
#     end
#   end_eval
# end
# 
# # if this is evaluated in a plugin with something like,
# #
# #     has_mixed_content, :only => [:static_image, :textile]
# #
# # Then we would define the ALLOWED_TYPES and perhaps even the other methods
# # there (@page.create_textile), modifying the class_eval as necessary.

class Content < ActiveRecord::Base
  
  belongs_to :container, :polymorphic => true
  belongs_to :item, :polymorphic => true
  
  # removed acts_as_list: interferes with new item order as they are being saved across validations
  # acts_as_list :scope => :container_id
  
  #before_save :convert_textile
      
  validates_associated :item
  
  attr_accessor :to_be_destroyed
  attr_accessor :temporary_id
  
  # return the actual id if it exists, otherwise make up a random id starting with a letter
  def temporary_id
    @temporary_id ||= id || "t#{self.__id__}"
  end
  
  before_update :save_item, :set_item_search_text
  
  def save_item
    item.save! if item
  end
  
  def set_item_search_text
    begin
      self.item_search_text = item.get_search_text if item
    rescue NoMethodError
      raise "get_search_text should be defined on acts_as_mixed_content models - model class here is #{self.item_type}"
    end
  end
  
  def convert_textile
    textile ||= ''
    html = RedCloth.new(textile).to_html
    html ||= ''
  end

  def item=(i)
    # best to pass item_type in hash
    # we can't be sure item_type= will be called before item= on content
    if i.is_a?(Hash)
      item_type = i.delete(:item_type)
      if self.item.nil? && self.item_type
        build_item item_type
      elsif self.item.nil? && item_type
        build_item item_type
      end
      # now update the object
      # self.item.attributes.merge(i) 
      self.item.attributes = i
    else 
      @item = i
    end
  end
  
  def build_item(item_type)
    # TODO: make this check whether the klass has "acts_as_mixed_content" instead of a static list
    # define allowed_types to prevent creating Users, for example
    allowed_types = %w{StaticImage Textile HelpInterruptor Slideshow DonateInterruptor DownloadLibrary AudioPlayer VideoPlayer ClickableImage}
    self.item_type = item_type = item_type.to_s.classify
    klass = item_type.constantize
    if klass.methods && allowed_types.include?(item_type)
      self.item = klass.new#(:content => self)
    end
    return self.item
  end

end
