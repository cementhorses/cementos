module Admin::PagesHelper
  
  def threaded_page_options( root = nil )
    unless root
      root = Page.find_by_frame_and_parent_id(@frame, nil)
    end
    return threaded_page_recurse( root )
  end
  
  def threaded_page_recurse( page, level = 0, pages = [ ] )
    return pages unless page
    pad = '. . '
    pages << [ (pad * level).to_s + page.name, page.id  ]
    page.children.each do |p|
      pages = threaded_page_recurse( p, level + 1, pages )
    end
    return pages
  end
  
end