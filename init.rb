require 'mixed_content'
ActiveRecord::Base.send :include, Cementos::MixedContent

ActionView::Base.send :include, Cementos::MixedContentHelper