class ThingsController < ApplicationController

  def index
    @things = Thing.order(:created_at).page(params[:page])
  end

  def search
    @things = Thing.search(params[:query]).page(params[:page])
  end

  def new
    @thing = Thing.new
  end
end
