class Page < ActiveRecord::Base

  # for strip_tags method in search_results_text
  include ActionView::Helpers::SanitizeHelper

  acts_as_tree :order => :position
  acts_as_list :scope => :parent_id
  
  has_mixed_content

  # is_indexed :fields => %w(name),
  #   :concatenate => [
  #     {:association_name => 'contents', :field => 'item_search_text', :as => 'search_text'}
  #   ],
  #   :conditions => "pages.published = 1 and contents.container_type = 'Page'"
    
  # belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by" # userstamp plugin
  
  before_validation :slugify, :build_path
  after_save :rebuild_path_recurse
           
  validates_presence_of :name
  validates_presence_of :template, :allow_blank => false
  validates_presence_of :slug, :if => :parent
  validates_uniqueness_of :slug, :scope => 'parent_id'
  validates_format_of :slug, :with => /^[a-z0-9\-]+$/, :message => "may only contain lowercase letters, numbers and dashes" 
  
  def validate
    errors.add(:parent, "cannot be self") if self.parent_id.to_i > 0 && self.parent_id == self.id
    errors.add(:slug, "contains invalid characters") if self.slug && self.slug.length != self.slug.chars.length
    contents.select{|c| !c.to_be_destroyed}.each do |content|
      unless content.valid?
        errors.add_to_base "Contents contain errors" 
        break
      end 
    end
  end
  
  # used by navigation views to determine whether to render children at all
  def visible_navigation_children
    children.select {|c| c.published? and c.display_in_navigation? }
  end
  
  def sort_children
    self.children.find(:all).each_with_index do |page, i|
      page.update_attribute(:position, i)
      memory = i + 1
    end
    self.children.find(:all).each_with_index do |page, i|
      page.update_attribute(:position, i + memory)
    end
  end
   
  def build_path
    slugs = self.ancestors.collect {|p| p.slug}
    slugs.reverse!
    slugs << self.slug
    self.path = '/' + slugs.join('/')
    self.frame = self.slug if self.parent_id.nil? # set frame to slug for root pages
    self.frame = self.root.frame if Page.frames.include?(self.root.frame)
  end
  
  def rebuild_path_recurse
    self.children.each do |p|
      p.build_path
      p.save!
      p.rebuild_path_recurse
    end
  end
  
  def Page.default_frame
    return Page.frames.first
  end
  
  def Page.frames
    return Page.find_all_by_parent_id(nil).collect{|p| p.slug}
    # return [ 'about-us', 'what-we-do', 'what-you-can-do', 'grants', 'global' ]
  end
  
  def Page.template_options
    # add hidden items to the "excluded" array
    excluded = ['load', 'home']
    options = Dir.entries("#{RAILS_ROOT}/app/views/pages")
    options = options.collect{|t| t.sub(/\.+.*/, '')}.select{|t| t !~ /\A_/}
    options += PagesController.instance_methods(false)
    options.delete_if { |i| excluded.include?(i) }
    options.uniq!
    options.sort!
    return options
  end
  
  def slugify
    slugify! if self.slug.blank?
  end
  
  def slugify!
    self.slug = self.name.downcase.gsub("'", '').gsub(/[^\w]+/, '-').gsub(/^-|-$/, '') 
  end
  
  # def search_results_text
  #   textiles = []
  #   self.contents.each { |c| textiles << strip_tags(c.item.html) if c.item_type == "Textile"}
  #   return textiles.to_s  
  # end
  
end
