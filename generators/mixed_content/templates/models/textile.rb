class Textile < ActiveRecord::Base
  
  include ActionView::Helpers::SanitizeHelper

  acts_as_mixed_content

  before_save :convert_textile
  
  def convert_textile
    # @textile ||= ''
    #     @html = RedCloth.new(textile).to_html
    write_attribute :textile, "" unless textile
    write_attribute :cached_html, RedCloth.new(textile).to_html
  end
  
  def get_search_text
    strip_tags(cached_html)
  end
  
end