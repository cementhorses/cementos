class MixedContentGenerator < Rails::Generator::Base

  default_options :skip_migration => false,
                  :textile => true,
                  :mixed_content => false,
                  :interface => :oldschool

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
      

      # Views
      m.directory 'app/views/admin/pages'
      m.file "views/admin/pages/#{options[:interface]}/index.html.erb", 'app/views/admin/pages/index.html.erb'
      m.file "views/admin/pages/#{options[:interface]}/_tree.html.erb", 'app/views/admin/pages/_tree.html.erb'
      m.file 'views/admin/pages/edit.html.erb', 'app/views/admin/pages/edit.html.erb'
      m.file 'views/admin/pages/new.html.erb', 'app/views/admin/pages/new.html.erb'
      m.file 'views/admin/pages/_form.html.erb', 'app/views/admin/pages/_form.html.erb'
      m.file 'views/admin/pages/_form_buttons.html.erb', 'app/views/admin/pages/_form_buttons.html.erb'
      m.directory 'app/views/layouts/admin'
      m.file 'views/layouts/admin/pages.html.erb', 'app/views/layouts/admin/pages.html.erb'
      m.directory 'app/views/site/pages'
      m.file 'views/site/pages/home.html.erb', 'app/views/site/pages/home.html.erb'
      m.file 'views/site/pages/generic.html.erb', 'app/views/site/pages/generic.html.erb'

      # Stylesheets
      m.file 'stylesheets/pages.css', 'public/stylesheets/pages.css'

      # Javascripts
      m.directory 'public/javascripts/admin'
      m.file 'javascripts/admin/mixed_content.js', 'public/javascripts/admin/mixed_content.js'

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

      # Tests
      m.file 'test/unit/page_test.rb', 'test/unit/page_test.rb'
      m.directory 'test/functional/admin'
      m.file 'test/functional/admin/pages_controller_test.rb', 'test/functional/admin/pages_controller_test.rb'
      m.directory 'test/functional/site'
      m.file 'test/functional/site/pages_controller_test.rb', 'test/functional/site/pages_controller_test.rb'
      m.file 'test/fixtures/pages.yml', 'test/fixtures/pages.yml'

      # Migration
      unless options[:skip_migration]
        m.migration_template "migrate/create_cementos_pages.rb", 'db/migrate', 
                             :migration_file_name => "create_cementos_pages"
      end

      # Routes
      # m.route_resources :pages

      # README
      m.readme('README')

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
      opt.on("--draggable-interface", 
              "Use the draggable pages admin interface") { |v| options[:interface] = :draggable }
    end

end