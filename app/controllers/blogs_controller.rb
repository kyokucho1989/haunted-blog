# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :ensure_blog_owner, only: %i[edit update destroy]
  before_action :authorize_secret_blog_access, only: %i[show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def ensure_blog_owner
    @blog = current_user.blogs.find(params[:id])
  end

  def authorize_secret_blog_access
    user_id = user_signed_in? ? current_user.id : nil
    @blog = Blog.where(user_id:, id: params[:id], secret: true).or(Blog.where(id: params[:id], secret: false)).first!
  end

  def blog_params
    permit_symbols = %i[title content secret]
    permit_symbols.push(:random_eyecatch) if current_user.premium
    params.require(:blog).permit(permit_symbols)
  end
end
