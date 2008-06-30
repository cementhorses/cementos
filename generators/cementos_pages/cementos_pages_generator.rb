class CementosPagesGenerator < Rails::Generator::NamedBase
  
  def manifest
    record do |m|
      
      # Controllers
      m.template 'controllers/pages_controller.rb', 'app/controllers/pages_controller.rb'
      m.directory 'app/controllers/admin'
      m.template 'controllers/admin/pages_controller.rb', 'app/controllers/admin/pages_controller.rb'
      
      # Helpers
      m.directory 'app/helpers/admin'
      m.file 'helpers/admin/pages_helper.rb', 'app/helpers/admin/pages_helper.rb'
      
      # Models
      m.template 'models/page.rb', 'app/models/page.rb'
      
      # Views
      m.directory 'app/views/pages'
      m.file 'views/pages/home.html.erb', 'app/views/pages/home.html.erb'
      m.file 'views/pages/generic.html.erb', 'app/views/pages/generic.html.erb'
      m.directory 'app/views/admin/pages'
      m.file 'views/admin/pages/index.html.erb', 'app/views/admin/pages/index.html.erb'
      m.file 'views/admin/pages/_tree.html.erb', 'app/views/admin/pages/_tree.html.erb'
      m.file 'views/admin/pages/edit.html.erb', 'app/views/admin/pages/edit.html.erb'
      m.file 'views/admin/pages/new.html.erb', 'app/views/admin/pages/new.html.erb'
      m.file 'views/admin/pages/_form.html.erb', 'app/views/admin/pages/_form.html.erb'
      m.file 'views/admin/pages/_form_buttons.html.erb', 'app/views/admin/pages/_form_buttons.html.erb'
      m.directory 'app/views/layouts/admin'
      m.file 'views/layouts/admin/pages.html.erb', 'app/views/layouts/admin/pages.html.erb'
      
      # Stylesheets
      m.file 'stylesheets/pages.css', 'public/stylesheets/pages.css'
      
      # Javascripts
      m.directory 'public/javascripts/admin'
      m.file 'javascripts/admin/pages.js', 'public/javascripts/admin/pages.js'
      
      # Images
      m.directory 'public/images/admin'
      m.directory 'public/images/admin/icons'
      m.file 'images/admin/icons/destroy.png', 'public/images/admin/icons/destroy.png'
      m.file 'images/admin/icons/move_down.png', 'public/images/admin/icons/move_down.png'
      m.file 'images/admin/icons/move_up.png', 'public/images/admin/icons/move_up.png'
      m.file 'images/admin/icons/edit.png', 'public/images/admin/icons/edit.png'
      m.file 'images/admin/icons/toggle_down.gif', 'public/images/admin/icons/toggle_down.gif'
      m.file 'images/admin/icons/toggle_right.png', 'public/images/admin/icons/toggle_right.png'
      m.file 'images/admin/icons/add_page.png', 'public/images/admin/icons/add_page.png'
      m.file 'images/admin/icons/preview_page.png', 'public/images/admin/icons/preview_page.png'
      
      # Migration
      m.migration_template "migrate/create_cementos_pages.rb", "db/migrate"
      
    end
  end
  
  
end