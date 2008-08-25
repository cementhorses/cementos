class Admin::MixedContentsController < ApplicationController
  
  
  def add_content
    @content = Content.new
    @content.container_id = params[:container_id].to_i
    @content.container_type = params[:container_type]
    # @content.id = params[:id].to_i if params[:id]
    @content.build_item params[:item_type] # unless params[:item_type].blank?
    @content.position = params[:position]
    # @content.save(false)
    # @content.save
    # @content.errors.clear
    # @content.item.errors.clear #unless @content.item_type == 'textile'
    @object_name = params[:object_name] # TODO: make this more flexible
    render :partial => 'mixed_content_item_editor.html.erb', :object => @content, :locals => {:object_name => @object_name}
  end
  
  def remove_content
    @content = Content.find_by_id params[:id].to_i
    if @content
      @content.to_be_destroyed = true
      render :update do |page|
        page.insert_html :bottom, :mixed_content, :partial => 'content', :locals => {:content => @content, :object_name => params[:object_name]}
      end
    else 
      render :nothing => true
    end
  end
  
  def add_sub_item
    klass = params[:sub_item_type].constantize
    @sub_item = klass.new
    @object_name = params[:object_name]
    render :partial => klass.name.underscore, :locals => {:sub_item => @sub_item, :object_name => @object_name}
  end
  
  def remove_sub_item
    klass = params[:sub_item_type].constantize
    @sub_item = klass.find_by_id params[:id].to_i
    if @sub_item
      @sub_item.to_be_destroyed = true
      render :partial => klass.name.underscore, :locals => {:sub_item => @sub_item, :object_name => params[:object_name]}
    else
      render :nothing => true
    end
  end
  
  def textile_reference
    render :layout => 'admin/layouts/reference'
  end
  
  
end
