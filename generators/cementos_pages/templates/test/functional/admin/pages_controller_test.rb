require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PagesControllerTest < ActionController::TestCase

  def test_should_get_index
    get :index, :frame => 'about'
    assert_response :success
    assert_not_nil assigns(:root)
  end

  def test_should_get_new
    get :new, :frame => 'about', :page => { :parent_id => pages(:about).id }
    assert_response :success
  end

  def test_should_create_page
    assert_difference('Page.count') do
      post :create, :frame => 'about', :page => { :parent_id => pages(:about).to_param, :name => 'A New Page' }
    end    
    assert_redirected_to admin_pages_path('about')
  end

  def test_should_get_edit
    get :edit, :frame => 'about', :id => pages(:about).to_param
    assert_response :success
  end

  def test_should_update_page
    put :update, :frame => 'about', :id => pages(:about).to_param, :page => { :name => 'Different About' }
    assert_redirected_to admin_pages_path('about')
  end

  def test_should_destroy_page
    assert_difference('Page.count', -1) do
      delete :destroy, :frame => 'about', :id => pages(:child_three)
    end
    assert_redirected_to admin_pages_path('about')
  end

end
