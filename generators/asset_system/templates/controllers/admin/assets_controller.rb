class Admin::AssetsController < ApplicationController

  before_filter :get_asset_type, :except => :index
  before_filter :get_asset,      :except => :index

  rescue_from 'ActiveRecord::InvalidRecord', :with => :validation_errors

  def index; render :nothing => true end # For hidden image-upload iframe

  def create
    @asset.save!
    @extra_partial = params[:extra_partial]
    respond_to do |format|
      format.js { respond_to_parent { render :action => 'create' } }
    end
  end

  def destroy
    @asset.destroy
    respond_to do |format|
      format.js
    end
  end

  protected

    def get_asset_type
      @asset_parent_class = params[:type].classify.constantize
      
      asset_name = params[:type]
      if !params[:asset_prefix].blank?
        asset_name = params[:asset_prefix].capitalize + asset_name
      end

      @association        = @asset_parent_class.reflect_on_association :"#{asset_name.underscore}_assets"
      @association      ||= @asset_parent_class.reflect_on_association :"#{asset_name.underscore}_asset"

      @asset_class        = @association.class_name.constantize
    end

    def get_asset
      @asset = if params[:id]
        @asset_class.find_by_id params[:id]
      else
        @asset_class.new params[:asset]
      end
    end

    def validation_errors
      respond_to do |format|
        format.js { respond_to_parent { render :action => 'asset_errors' } }
      end
    end

end
