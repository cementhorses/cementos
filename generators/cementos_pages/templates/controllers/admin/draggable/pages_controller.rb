class Admin::PagesController < ApplicationController
  
  before_filter :get_frame
  before_filter :get_pages, :only => :index
  before_filter :get_page, :except => [:index, :insert_image, :insert_page, :sort]

  # precautionary
  # log_changes :page,
  #   :created => Proc.new { |page| page.status or 'created' },
  #   :updated => Proc.new { |page| page.status or 'updated' }
    
  # render index, new, edit
    
  def create
    @page.save!
    flash[:notice] = "'#{@page.name}' #{@page.status or 'created'}!"
    respond_to do |format|
      format.html { redirect_to determined_path }
      format.js   { js_redirect determined_path }
    end
  end

  def update
    @page.update_attributes! params[:page]
    flash[:notice] = "'#{@page.name}' #{@page.status or 'updated'}!"
    respond_to do |format|
      format.html { redirect_to determined_path }
      format.js   { js_redirect determined_path }
    end
  end

  def destroy
    @page.destroy and get_pages
    respond_to do |format|
      format.html { redirect_to admin_pages_url }
      format.js
    end
  end
  
  # ===

    # log_changes :child, :insert_page => 'repositioned'
    # log_changes :dragged_page, :sort => 'repositioned'
    
  def insert_page
    if params[:id] == 'create_a_new_page'
      render :update do |page|
        page.redirect_to new_admin_page_path(:page => { :parent_id => params[:parent] })
      end
    else
      parent = Page.find params[:parent]
      @child = Page.find params[:id][/\d+/]
      @child.update_attribute(:parent_id, parent.id) unless @child == parent
      @child.move_to_bottom
      get_pages
      render :update do |page|
        page.replace 'tree_root', :partial => 'tree', :locals => { :pages => [ @root ], :parent => false }
      end
    end
  end
  
  def sort
    @dragged_page = Page.find params[:id][/\d+/]
    if params[:before]
      dropped_near_page = Page.find params[:before]
      @dragged_page.goes_before dropped_near_page
    else
      dropped_near_page = Page.find params[:after]
      @dragged_page.goes_after dropped_near_page
    end
    get_pages
    render :update do |page|
      page.replace 'tree_root', :partial => 'tree', :locals => { :pages => [ @root ], :parent => false }
    end
  end
  
  def get_template
    respond_to do |format|
      format.js
    end
  end
  
  def insert_image
    @image = PageImage.find params[:id][/\d+/]
    respond_to do |format|
      format.js
    end
  end
  
  protected
  
    def get_frame
      @frame = params[:frame] || Page.default_frame
      @frame = Page.default_frame unless Page.frames.include?(@frame)
    end
    
    def get_pages
      @root = Page.find_by_path "/#@frame"
    end
    
    def get_page
      params[:page][:embedded_images] ||= {} if params[:page]
      @page = if params[:id]
        Page.find params[:id]
      else
        Page.new params[:page]
      end
      if params[:publish]
        @page.published_at ||= Time.now
      else
        @page.published_at = nil
      end if request.post? or request.put?
      raise 'page[parent_id] required' if @page.new_record? and not (@page.parent_id or request.xhr?)
    end
    
    def determined_path
      if @page.ticker_flag and @page.ticker_item.nil?
        new_admin_ticker_item_path(:content => dom_id(@page))
      else
        admin_pages_path
      end
    end
  
    # Cache methods - TODO: reëvaluate caching methods for memcached), e.g.,
    # - Interlock, http://blog.evanweaver.com/files/doc/fauna/interlock/files/README.html
    # - Memcached, http://blog.evanweaver.com/articles/2008/01/21/b-the-fastest-u-can-b-memcached/
  
    def expire_cache_through_parent
      expire_through(@page.parent) if @page.parent
    end
  
    def expire_cache
      @page.parent ? expire_through(@page.parent) : expire_through(@page)
    end
  
    def expire_through(p)
      p.children.each do |c|
        expire_through(c)
      end if p && p.children.size > 0
      self.class.expire_page(p.path)
    end
  
end
