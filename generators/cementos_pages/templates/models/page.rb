require 'iconv'

# This exception is raised when a page cannot be destroyed, namely, when it is
# a root/frame page.
class UndestroyableError < RuntimeError; end

# This exception is raised when a page has children and the attempt is made to
# destroy it. Rescue in order to force destruction, but make sure its children
# are accounted for.
class HasAssociatedError < RuntimeError; end

# This exception is raised when a page is required and the attempt is made to
# destroy it.
class RequiredPageError < RuntimeError; end

# The page model, a CMS staple.
class Page < ActiveRecord::Base
  # For strip_tags method in search_results_text
  include ActionView::Helpers::SanitizeHelper

  acts_as_tree :order => :position
  acts_as_list :scope => :parent_id

  class << self
    def default_frame
      frames.first
    end

    def frames
      find_all_by_parent_id(nil).collect { |page| page.slug }
      # Use the line below instead to define frames without using the database
      # return [ 'about', 'products', 'events' ]
    end

    def template_options
      # Add hidden items to the "excluded" array
      excluded = ['load', 'home']
      options = Dir.entries("#{RAILS_ROOT}/app/views/site/pages")
      options = options.collect{ |t| t.sub(/\.+.*/, '') }.select{ |t| t !~ /\A_/ }
      options += Site::PagesController.instance_methods(false)
      options.delete_if { |i| excluded.include?(i) }
      options.uniq!
      options.sort!
    end
  end

  after_initialize :set_template_to_generic
  before_validation :slugify, :build_path
  after_save :rebuild_path_recurse
  before_destroy :check_associated

  validates_presence_of :name
  validates_presence_of :template
  validates_presence_of :slug, :if => :has_parent?
  validates_uniqueness_of :slug, :scope => :parent_id
  validates_format_of :slug, :with => /^[a-z0-9\-]+$/,
    :message => 'may only contain lowercase letters, numbers and dashes'
  validate :should_not_be_parent_of_self

  # Used by navigation views to determine whether to render children at all.
  # (Should this move to a helper?)
  def visible_navigation_children
    children.select { |c| c.published? and c.display_in_navigation? }
  end
  
  def cache?
    return false unless perform_caching?
    return :action if members_only?
    return :page # otherwise
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

  protected

    def set_template_to_generic
      self.template ||= 'generic'
    end

    def slugify
      slugify! if slug.blank?
    end

    def slugify!
      self.slug = Iconv.iconv('ascii//translit', 'utf-8', name).to_s.downcase.
        strip.gsub(/[\s_-]/, '-').gsub(/[^\w-]/, '').gsub(/\-+/, '-')
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
      self.frame = root.frame
      path
    end

    def rebuild_path_recurse
      # Page#find must be called to circumvent dirty attribute freezing
      children.find(:all).each do |child|
        child.build_path
        child.save!
        child.rebuild_path_recurse
      end
    end

    def should_not_be_parent_of_self
      errors.add(:parent_id, 'cannot be self') if id == parent_id && !new_record?
    end

    def check_associated
      case
      when !has_parent?
        raise UndestroyableError, "#{name} is a root page and cannot be destroyed"
      when !children.empty?
        raise HasAssociatedError, "#{name}'s children must be deleted first"
      when !immutable_name.nil?
        raise RequiredPageError, "#{name} is a required page and cannot be destroyed"
      end
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
#     self.contents.inject([]) { |textiles, content|
#       textiles << strip_tags(content.item.html) if content.item_type == "Textile"
#     }.to_s
#   end

# Userstamp plugin
# ----------------
#   belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by"
