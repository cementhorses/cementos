require 'iconv'

# This exception is raised when a page cannot be destroyed, namely, when it is
# a root/frame page.
class UndestroyableError < RuntimeError; end

# This exception is raised when a page has children and the attempt is made to
# destroy it. Rescue in order to force destruction, but make sure its children
# are accounted for.
class HasAssociatedError < RuntimeError; end

# The page model, a CMS staple.
class Page < ActiveRecord::Base
  # For strip_tags method in search_results_text
  include ActionView::Helpers::SanitizeHelper

  acts_as_tree :order => :position
  acts_as_list :scope => :parent_id

  before_validation :slugify, :build_path
  after_save :rebuild_path_recurse
  before_destroy :check_associated

  validates_presence_of :name
  validates_presence_of :template
  validates_presence_of :slug, :if => :has_parent?
  validates_uniqueness_of :slug, :scope => :parent_id
  validates_format_of :slug, :with => /^[a-z0-9\-]+$/, :message => 'may only contain lowercase letters, numbers and dashes'
  validate :should_not_be_parent_of_self

  # Used by navigation views to determine whether to render children at all.
  # (Should this move to a helper?)
  def visible_navigation_children
    children.select { |c| c.published? and c.display_in_navigation? }
  end

  def has_parent?
    !parent_id.nil?
  end

  def sibling_of?(page)
    parent_id == page.parent_id
  end

  def siblings
    self_and_siblings - self
  end

  def siblings?
    parent.children.count > 1
  end

  def goes_before(another_page)
    if sibling_of? another_page and position < another_page.position
      insert_at another_page.position - 1
    else
      unless sibling_of? another_page
        remove_from_list
        update_attribute(:parent_id, another_page.parent_id)
      end
      insert_at another_page.position
    end
  end

  def goes_after(another_page)
    update_attribute(:parent_id, another_page.parent_id) unless sibling_of? another_page
    insert_at another_page.position + 1
  end

  class << self
    def default_frame
      frames.first
    end

    def frames
      find_all_by_parent_id(nil).collect{ |p| p.slug }
      # use the line below instead to define frames without using the database
      # return [ 'about', 'what-we-do', 'events' ]
    end

    def template_options
      # add hidden items to the "excluded" array
      excluded = ['load', 'home']
      options = Dir.entries("#{RAILS_ROOT}/app/views/pages")
      options = options.collect{|t| t.sub(/\.+.*/, '')}.select{|t| t !~ /\A_/}
      options += PagesController.instance_methods(false)
      options.delete_if { |i| excluded.include?(i) }
      options.uniq!
      options.sort!
    end
  end

  protected

    def slugify
      slugify! if slug.blank?
    end

    def slugify!
      self.slug = Iconv.iconv('ascii//translit', 'utf-8', self.name).to_s.
        downcase.strip.gsub(/[\s_-]/, '-').gsub(/[^\w-]/, '').gsub(/\-/, '-')
    end

    def sort_children
      memory = 0
      children.each_with_index do |page, i|
        page.update_attribute(:position, i)
        memory += 1
      end
      children.each_with_index do |page, i|
        page.update_attribute(:position, i + memory)
      end
    end

    def build_path
      slugs = ancestors.collect { |page| page.slug }.reverse! << self.slug
      self.path = '/' + slugs * '/'
      # Set frame to slug for root pages
      self.frame = if has_parent?
        slug
      elsif Page.frames.include?(root.frame)
        root.frame
      end
      path
    end

    def rebuild_path_recurse
      children.each do |child|
        child.build_path
        child.save!
        child.rebuild_path_recurse
      end
    end

    def should_not_be_parent_of_self
      errors.add(:parent_id, 'cannot be self') if id == parent_id
    end

    def check_associated
      raise HasAssociatedError, "#{name}'s children must be deleted first" unless children.empty?
      raise UndestroyableError, "#{name} cannot be destroyed" if self == root
    end

end

# These code snippets to be used if the associated plugins are used
# =================================================================
# 
# Mixed content plugin
# --------------------
#   has_mixed_content
#   
#   :validate content_should_be_valid
#   
#   protected
#   
#     def content_should_be_valid
#       contents.select{ |c| !c.to_be_destroyed }.each do |content|
#         unless content.valid?
#           errors.add_to_base "Contents contain errors" 
#           break
#         end 
#       end
#     end

# Ultrasphinx plugin
# ------------------
#   is_indexed :fields => %w(name),
#     :concatenate => [{
#       :association_name => 'contents',
#       :field => 'item_search_text',
#       :as => 'search_text'
#     }],
#     :conditions => "pages.published = 1 and contents.container_type = 'Page'"
# 
#   def search_results_text
#     textiles = []
#     self.contents.each { |c| textiles << strip_tags(c.item.html) if c.item_type == "Textile"}
#     return textiles.to_s  
#   end

# Userstamp plugin
# ----------------
#   belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by"
