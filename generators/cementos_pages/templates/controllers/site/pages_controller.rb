class Site::PagesController < ApplicationController
  
  before_filter :load, :except => :home

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
      @frame, @path = (params[:frame] || ''), (params[:path] || [])
      long_path = '/' + File.join(@frame, @path)
      long_path.chop! if long_path.ends_with?('/') # Fails to find '/:frame/'
      @page = Page.find_by_path(long_path)
      if @page and @page.published?
        __send__(@page.template) if respond_to?(@page.template)
        render :action => @page.template unless performed?
      else
        raise ActiveRecord::RecordNotFound
      end
    end

end