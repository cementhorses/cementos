require File.dirname(__FILE__) + '/../test_helper'

class PageTest < ActiveSupport::TestCase

  # about
  #   |
  #   +-- child_one
  #   |
  #   +-- child_two
  #   |     |
  #   |     +-- child_two_one
  #   |     |
  #   |     +-- child_two_two
  #   |           |
  #   |           +-- child_two_two_one
  #   |
  #   +-- child_three
  #   |
  #   +-- child_four
  #         |
  #         +-- child_four_one

  def setup
    @new_page = Page.new
    @root_page_with_children = pages(:about)
    @root_page_with_no_children = pages(:reference)
    @child_one = pages(:child_one)
    @child_two = pages(:child_two)
    @child_two_two = pages(:child_two_two)
    @child_two_two_one = pages(:child_two_two_one)
  end

  def test_fixtures
    assert @root_page_with_children.valid?
    assert @root_page_with_no_children.valid?
    assert @child_one.valid?
    assert @child_one.has_parent?
    assert !@root_page_with_children.has_parent?
    assert @child_one.sibling_of?(@child_two)
  end

  def test_new_page_should_be_invalid
    assert !@new_page.valid?
    assert_equal @new_page.template, 'generic'
  end

  def test_saved_page_should_generate_path
    page = Page.create(:parent_id => @child_two_two_one.id, :name => 'Child Two Two One One', :text => 'How deep can we go?')
    assert_equal page.path, "#{page.parent.path}/#{page.slug}"
  end

  def test_text_should_be_cached
    page = Page.create(:parent_id => @root_page_with_children.id, :name => 'New Child', :text => "It's a ***boy***!")
    assert page.cached_text
    assert_equal page.cached_text, RDiscount.new(page.text.to_s, :smart).to_html
  end

  def test_page_with_children_should_not_be_deleted
    assert_raise HasAssociatedError do
      @child_two.destroy
    end
  end

  def test_root_page_should_not_be_deleted
    assert_raise UndestroyableError do
      @root_page_with_no_children.destroy
    end
  end

  def test_sorting_and_parenting
    assert @child_one.first?
    assert_equal @child_one.parent, @root_page_with_children
    @child_one.goes_before @child_two_two
    assert !@child_one.first?
    assert @child_one.parent_id != @root_page_with_children.id

    assert_equal Page.find_by_name('Child Two One').position, 1
    assert_equal Page.find_by_name('Child Two Two').position, 3
  end

end
