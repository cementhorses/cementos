  module MixedContentHelper
    
    # mixed_content_editor :container => @page
    def mixed_content_editor( options = {} ) 
      raise ArgumentError, 'Missing a valid mixed content container' unless options[:container].is_a?(ActiveRecord::Base)
      options.merge!({  :association_name => :contents,
                        :default_content_type => nil
      })
      options.merge!({  :object_name => "#{options[:container].class.to_s.underscore}[#{options[:association_name]}]"
      })
      locals = {  :container => options[:container],
                  :collection => options[:container].send(options[:association_name].to_sym),
                  :object_name => options[:object_name],
                  :association_name => options[:association_name]
      }
      # render :partial => 'mixed_content_editor', :locals => locals
      render :partial => find_partial('mixed_content_area_editor'), :locals => locals
    end
    
    def find_partial( partial )
      if File.exist? "#{local_views_path}/_#{partial}.html.erb"
        "admin/mixed_contents/#{partial}"
      else
        "#{plugin_views_path}/#{partial}.html.erb"
      end
    end
    
    protected
    def local_views_path;         "#{RAILS_ROOT}/app/views/admin/mixed_contents" end
    def plugin_views_path;        "../../vendor/plugins/cementos/views/mixed_content" end
   
  end 
