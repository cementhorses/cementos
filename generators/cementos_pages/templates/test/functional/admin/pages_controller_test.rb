require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PagesControllerTest < ActionController::TestCase

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:root)
  end

  def test_should_get_new
    get :new, :page => { :parent_id => pages(:about).id }
    assert_response :success
  end

  def test_should_create_page
    assert_difference('Page.count') do
      post :create, :page => { :parent_id => pages(:about).to_param, :name => 'A New Page' }
    end    
    assert_redirected_to admin_pages_path
  end

  def test_should_get_edit
    get :edit, :id => pages(:about).to_param
    assert_response :success
  end

  def test_should_update_page
    put :update, :id => pages(:about).to_param, :page => { :text => 'New About' }
    assert_redirected_to admin_pages_path
  end

  def test_should_destroy_page
    assert_difference('Page.count', -1) do
      delete :destroy, :id => pages(:child_three)
    end
    assert_redirected_to admin_pages_path
  end

  def test_should_sort_pages
    assert Page.find(3).parent_id == 1

    xhr :put, :sort, :id => 'page_3', :before => '6'
    assert_response :success

    assert Page.find(3).parent_id != 1
  end

end
