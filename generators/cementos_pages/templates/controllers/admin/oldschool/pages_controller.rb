class Admin::PagesController < ApplicationController

  before_filter :get_frame
  before_filter :get_page, :except => :index
  after_filter :expire_cache, :only => [:update, :destroy]

  rescue_from ActiveRecord::RecordInvalid, :with => :record_invalid
  rescue_from ActiveRecord::StaleObjectError, :with => :stale_object_error

  # render index, new, edit

  def show
    respond_to do |format|
      format.html { redirect_to @page.path }
    end
  end

  def create
    @page.save!
    flash[:notice] = "Page created: #{@page.path}"
    respond_to do |format|
      format.html { redirect_to admin_pages_url }
    end
  end

  def update
    @page.update_attributes! params[:page]
    flash[:notice] = "Page saved: #{@page.path}"
    respond_to do |format|
      format.html do
        if params[:commit] == 'Save'
          render :action => 'edit'
        else
          redirect_to admin_pages_path 
        end
      end
    end
  end

  def destroy
    @page.destroy
    @page.parent.sort_children
    expire_cache
    flash[:notice] = "Page deleted: #{@page.path}"

    respond_to do |format|
      format.html { redirect_to admin_pages_url }
    end
  end

  # ===

  def tree_toggle
    session[:tree_toggles] = {} unless session[:tree_toggles]
    session[:tree_toggles][params[:id]] = params[:state] == 'true'
  end

  def up
    move :up
  end

  def down
    move :down
  end

  private

    def get_frame
      if Page.frames.include?(params[:frame])
        @frame = params[:frame]
        @root = Page.find_by_frame_and_parent_id(@frame, nil)
      elsif Page.default_frame
        redirect_to admin_pages_path(Page.default_frame)
      else
        raise "No frames exist (page section root nodes). Please create one or more pages without parents."
      end
    end

    def get_page
      @page = if params[:id]
        Page.find params[:id]
      else
        Page.new params[:page]
      end
    end

    def move(direction)
      flash[:notice] = if @page.parent
        @page.__send__ case direction
          when :up   then :move_higher
          when :down then :move_lower
        end
        @page.parent.sort_children
        expire_cache
        "Page moved: #{@page.path}"
      else
        'Cannot move the root page.'
      end
      respond_to do |format|
        format.html { redirect_to admin_pages_url }
      end
    end

    def record_invalid
      render :action => case params[:action]
        when 'create' then 'new'
        when 'update' then 'edit'
      end
    end

    def stale_object_error
      @page.reload
      @page.errors.add_to_base 'This page has been modified since you started editing it.'
      render :action => 'edit'
    end

    def expire_cache
      @page.parent ? expire_through(@page.parent) : expire_through(@page)
    end

    def expire_through(page)
      page.children.each do |child|
        expire_through(child)
      end
      self.class.expire_page(page.path)
    end

end
