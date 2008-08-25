module Cementos
  module MixedContent
   
      def self.included(mod)
        mod.extend(ClassMethods)
      end
      
      module ClassMethods
        
        def acts_as_mixed_content
          has_one :content, :as => 'item'
          class_eval <<-"end_eval"
            # needed to imitate builder
            def target
              self
            end

            # needed to imitate builder
            def updated?
              true
            end
          end_eval
        end
      
        def has_mixed_content(association_name = :contents, options = {})
          configuration = { :association_name => association_name, :allowed_types => :all }
          configuration.update(options) if options.is_a?(Hash)
          
          has_many configuration[:association_name], :order => 'position ASC', :as => :container do
            #TODO: add dependent option
              def update_from_params(params_hash = {})
              params_hash.each do |content_id, content_fields|
                if content = self.detect{|c| c.id == content_id.to_i} # update content if already attached to this container
                  content.attributes = content_fields
                else # otherwise create content on model
                  self.build(content_fields)
                end
              end
              self.sort!{|x,y| x.position <=> y.position}
            end  
          end
                    
          alias_method "pre_mixed_content_#{configuration[:association_name].to_s}=".to_sym, "#{configuration[:association_name].to_s}=".to_sym
          
          after_update "save_#{configuration[:association_name].to_s}".to_sym
                      
          class_eval <<-"end_eval"

            # intercept a hash
            def #{configuration[:association_name].to_s}=(c)
              if c.is_a?(Hash)
                #{configuration[:association_name].to_s}.update_from_params(c)
              else
                pre_mixed_content_#{configuration[:association_name].to_s}=(c)
              end
            end
            
            def #{configuration[:association_name].to_s}_mixed_content_types
              ['Image', 'Textile']
            end

            # need this to preserve order fields
            def save_#{configuration[:association_name].to_s}
              self.#{configuration[:association_name].to_s}.each do |c|
                if c.to_be_destroyed
                  c.destroy #TODO: make this handle dependent destroy?
                else
                  c.save
                end
              end
            end
          end_eval
        end
      
      end
    
  end
end