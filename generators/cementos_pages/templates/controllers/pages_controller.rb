class PagesController < ApplicationController
  before_filter :load, :except => :home

  # helper 'admin/contents'

  # special action for homepage, not a template like the actions below
  def home
   
  end

  ### template actions ###
  # please alphabetize!

  # this action will run for any page whose template is set to 'generic'
  def generic
    # this will look for pages/generic.html.erb by default...
    # or it could use :render, just like a normal action
  end

  ### end template actions ###

  protected

  def load
    params[:path] ||= [ ]
    @frame = params[:frame] || ''
    path = '/' + File.join(@frame, params[:path])
    path.chop! if path.ends_with?('/') # Attempt fails to find '/:frame/'
    @page = Page.find_by_path(path)
    if @page and (@page.published?)
      self.send(@page.template) if self.respond_to?(@page.template)
      render :action => @page.template unless performed?
    else
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
      return
    end
  end

end