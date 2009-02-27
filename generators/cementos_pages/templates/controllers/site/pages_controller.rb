class Site::PagesController < ApplicationController
  
  before_filter :load_page, :except => :home # get the @page object to decide how to cache it
  caches_action :index, :if => Proc.new{|c| c.instance_variable_get("@page") && c.instance_variable_get("@page").cache? == :action }
  before_filter :load, :except => :home
  
  # uncomment this line to cache the home page as well
  # caches_page :home


  # == Begin Template Actions

  # This action will run for any page with a "generic" template. It will look
  # for "pages/generic.html.erb" by default, but any template can be rendered.
  def generic
  end

  # == End Template Actions

  # Special action for homepage (not a template)
  def home
  end

  protected
  def load
    if @page && @page.published?
      if @page.members_only && !logged_in?
        login_required
      else
        self.send(@page.template) if self.respond_to?(@page.template)
        render :action => @page.template unless performed?
        # Cache page based off conditionals
        cache_page if @page && @page.cache? == :page
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def load_page
    params[:path] ||= [ ]
    @frame = params[:frame] || ''
    path = '/' + File.join(@frame, params[:path])
    path.chop! if path.ends_with?('/') # Attempt fails to find '/:frame/'
    @page = Page.find_by_path(path)
  end

end