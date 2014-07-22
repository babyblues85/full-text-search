class ThingsController < ApplicationController

  def index
    @things = Thing.order("created_at DESC").page(params[:page])
  end

  def search
    @things = Thing.search(params[:query]).page(params[:page])
  end

  def new
    @thing = Thing.new
  end

  def create
    @thing = Thing.new
    @thing.content = params[:thing][:content]
    if @thing.save
      redirect_to root_path
    else
      render :new
    end
  end
end
