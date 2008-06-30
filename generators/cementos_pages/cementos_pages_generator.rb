class CementosPagesGenerator < Rails::Generator::NamedBase
  
  def manifest
    record do |m|
      
      # Controllers
      m.file 'controllers/pages_controller.rb', 'app/controllers/pages_controller.rb'
      m.directory 'app/controllers/admin'
      m.file 'controllers/admin/pages_controller.rb', 'app/controllers/admin/pages_controller.rb'
      
      # Models
      m.file 'models/page.rb', 'app/models/page.rb'
      
      # Views
      m.directory 'app/views/pages'
      m.file 'views/pages/home.html.erb', 'app/views/pages/home.html.erb'
      m.directory 'app/views/admin/pages'
      m.file 'views/admin/pages/index.html.erb', 'app/views/admin/pages/index.html.erb'
      m.file 'views/admin/pages/_tree.html.erb', 'app/views/admin/pages/_tree.html.erb'
      
      # Migration
      m.migration_template "migrate/create_pages.rb", "db/migrate"
      
    end
  end
  
  
end