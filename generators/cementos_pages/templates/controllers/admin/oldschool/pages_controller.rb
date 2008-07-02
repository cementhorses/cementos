class Admin::PagesController < ApplicationController
  
  before_filter :get_frame
  before_filter :get_page, :only => [:show, :new, :create, :edit, :update, :destroy, :up, :down]
  
  def index
    @root = Page.find_by_frame_and_parent_id(@frame, nil)
  end
    
  def tree_toggle
    session[:tree_toggles] = { } unless session[:tree_toggles]
    session[:tree_toggles][params[:id]] = (params[:state] == 'true')
  end

  def show
    redirect_to @page.path
  end
  
  # new
  
  # edit
  
  def create
    @page = Page.new(params[:page])
    # @page.edited_at = Time.now
    if @page.save
      flash[:notice] = "Page created: #{@page.path}"
      redirect_to admin_pages_url
    else
      render :action => "new"
    end
  end

  def update
    @page = Page.find(params[:id])
    # @page.edited_at = Time.now
    # @app_settings = AppSettings.instance
    expire_cache
    @page.update_attributes(params[:page])
    # @app_settings.update_attributes(params[:app_settings]) if params[:app_settings]
    if @page.valid? #@app_settings.valid? && @page.valid?
      flash[:notice] = "Page saved: #{@page.path}"
      if params[:commit] == 'Save' # save and reload edit interface
        render :action => 'edit'
      else # save and done editing
        redirect_to admin_pages_path
      end
    else
      render :action => "edit"
    end
  rescue ActiveRecord::StaleObjectError
    @page.reload
    @page.errors.add_to_base 'Version inconsistency - this record has been modified since you started editing it.'
    render :action => 'edit'
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    expire_cache
    unless @page
      flash[:notice] = 'Could not delete. Page does not exist.'
      redirect_to admin_pages_url
      return
    end
    if @page.parent_id.nil?
      flash[:notice] = "Cannot delete root page"
    elsif !@page.immutable_name.nil?
      flash[:notice] = "Cannot delete required page"
    elsif !@page.children.empty?
      flash[:notice] = "Cannot delete a page with sub-pages"
    else
      @parent = @page.parent
      @page.destroy
      @parent.sort_children
      flash[:notice] = "Page deleted: #{@page.path}"
    end
    redirect_to admin_pages_url
  end
  
  def up
    if @page.parent
      @page.move_higher
      @page.parent.sort_children
      expire_cache
      flash[:notice] = "Page moved: #{@page.path}"
    else
      flash[:notice] = 'Cannot move the root page.'
    end
    redirect_to admin_pages_path
  end
  
  def down
    if @page.parent
      @page.move_lower
      @page.parent.sort_children
      expire_cache
      flash[:notice] = "Page moved: #{@page.path}"
    else
      flash[:notice] = 'Cannot move the root page.'
    end  
    redirect_to admin_pages_path
  end

  
  private
  def get_frame
    @frame = params[:frame]
    unless Page.frames.include?(@frame)
      @frame = Page.default_frame
      if @frame 
        redirect_to admin_pages_path(@frame)
      else  
        raise "No frames exist (page section root nodes). Please create one or more pages without parents."
      end
    end
  end
  
  def get_page
    @page = Page.find(params[:id]) if params[:id]
    @page ||= Page.new(:template => 'generic')
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
