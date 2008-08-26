class AssetSystemGenerator < Rails::Generator::Base

  default_options :skip_migration => false

  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    record do |m|

      # Controllers
      m.directory 'app/controllers/admin'
      m.file "controllers/admin/assets_controller.rb", 'app/controllers/admin/assets_controller.rb'

      # Helpers
      # included in plugin

      # Models
      m.file 'models/asset.rb', 'app/models/asset.rb'
      

      # Views
      m.directory 'app/views/admin'
      m.directory 'app/views/admin/assets'
      m.file 'views/admin/assets/_asset_uploader.html.erb', 'app/views/admin/assets/_asset_uploader.html.erb'
      m.file 'views/admin/assets/_assets_form.html.erb', 'app/views/admin/assets/_assets_form.html.erb'
      m.file 'views/admin/assets/asset_errors.js.rjs', 'app/views/admin/assets/asset_errors.js.rjs'
      m.file 'views/admin/assets/create.js.rjs', 'app/views/admin/assets/create.js.rjs'
     
      # Stylesheets

      # Javascripts
      # m.directory 'public/javascripts/admin'
      # m.file 'javascripts/admin/mixed_content.js', 'public/javascripts/admin/mixed_content.js'

   
      # Tests
    

      # Migration
      unless options[:skip_migration]
        m.migration_template "migrate/create_assets.rb", 'db/migrate', 
                             :migration_file_name => "create_assets"
      end

      # Routes
      # m.route_resources :pages

      # README
      # m.readme('README')

    end
  end

  protected

    def banner
      "Usage: #{$0} asset_system"
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