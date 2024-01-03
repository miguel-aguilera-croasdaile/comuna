class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @products = Product.where("quantity > :quantity", quantity: 0)
    if params[:brand].present?
      @query = params[:brand]
      @products = @products.where(brand: params[:brand])
    elsif params[:size].present?
      @query = params[:size]
      @products = @products.where(size: params[:size])
    elsif params[:year].present?
      @query = params[:year]
      @products = @products.where(year: params[:year])
    else
      @query = "All"
    end
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save!
      flash[:notice] = "Product created."
      redirect_to product_path(@product)
    else
      render product_new
    end
  end

  private

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :price,
      :delivery_fee,
      :brand,
      :material,
      :size,
      :color,
      :condition,
      :quantity,
      photos: [],
    )
  end
end
