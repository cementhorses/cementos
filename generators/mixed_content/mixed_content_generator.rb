class MixedContentGenerator < Rails::Generator::Base

  default_options :skip_migration => false

  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    record do |m|

      # Controllers
      m.directory 'app/controllers/admin'
      m.file "controllers/admin/mixed_contents_controller.rb", 'app/controllers/admin/mixed_contents_controller.rb'

      # Helpers
      # included in plugin

      # Models
      # content model included in plugin
      m.file 'models/textile.rb', 'app/models/textile.rb'
      m.file 'models/image.rb', 'app/models/image.rb'
      m.file 'models/image_asset.rb', 'app/models/image_asset.rb'
      

      # Views
      m.directory 'app/views/admin'
      m.directory 'app/views/admin/mixed_contents'
      m.file "views/admin/mixed_contents/_mixed_content_area_editor.html.erb", 'app/views/admin/mixed_contents/_mixed_content_area_editor.html.erb'
      m.file "views/admin/mixed_contents/_mixed_content_item_editor.html.erb", 'app/views/admin/mixed_contents/_mixed_content_item_editor.html.erb'
      m.file "views/admin/mixed_contents/_textile_editor.html.erb", 'app/views/admin/mixed_contents/_textile_editor.html.erb'
      m.file "views/admin/mixed_contents/textile_reference.html.erb", 'app/views/admin/mixed_contents/textile_reference.html.erb'
      m.file 'views/admin/mixed_contents/_image_editor.html.erb', 'app/views/admin/mixed_contents/_image_editor.html.erb'
      m.directory 'app/views/layouts/admin'
      m.file 'views/layouts/admin/reference.html.erb', 'app/views/layouts/admin/reference.html.erb'
      
      m.directory 'app/views/mixed_content'
      m.file 'views/mixed_content/_textile.html.erb', 'app/views/mixed_content/_textile.html.erb'
      m.file 'views/mixed_content/_image.html.erb', 'app/views/mixed_content/_image.html.erb'
      m.file 'views/mixed_content/_content.html.erb', 'app/views/mixed_content/_content.html.erb'
      
     
      # Stylesheets

      # Javascripts
      m.directory 'public/javascripts/admin'
      m.file 'javascripts/admin/mixed_content.js', 'public/javascripts/admin/mixed_content.js'

      # Migration
      unless options[:skip_migration]
        m.migration_template "migrate/create_contents.rb", 'db/migrate', 
                             :migration_file_name => "create_contents"
        m.migration_template "migrate/create_textiles.rb", 'db/migrate', 
                            :migration_file_name => "create_textiles"
        m.migration_template "migrate/create_images.rb", 'db/migrate', 
                            :migration_file_name => "create_images"                
      end

      # Routes
      # m.route_resources :pages

      # README
      # m.readme('README')

    end
  end

  protected

    def banner
      "Usage: #{$0} cementos_pages"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file for the pages model") { |v| options[:skip_migration] = v }
    end

end

# http://blog.stonean.com/2008/06/generators-and-timestamped-migrations.html
if Rails::VERSION::MAJOR >= 2 && Rails::VERSION::MINOR >= 1
  class Rails::Generator::Commands::Base
    protected
    def next_migration_string(padding = 3)
      sleep(1)
      Time.now.utc.strftime("%Y%m%d%H%M%S") 
    end
  end
end