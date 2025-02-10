class Api::PostsController < ApplicationController
  def create
    user = User.find_or_create_by(login: post_params[:login])
    post = user.posts.build(post_params.except(:login))
  
    if post.save
      render json: { post: post, user: user }, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def top_posts
    top_posts = Post.top_posts_by_avg_rating(params[:limit] || 10)
    top_posts_attributes = top_posts.map { |post| post.slice(:id, :title, :body) }
  
    render json: top_posts_attributes, status: :ok
  rescue ArgumentError => e
    render json: { errors: 'Invalid limit parameter' }, status: :unprocessable_entity
  end
 
  def ips
    ips_list = Post.ips_posted_by_diff_authors
    formatted_ips_list = ips_list.group_by(&:ip).map do |ip, posts|
      { ip: ip, authors: posts.map(&:login) }
    end

    render json: formatted_ips_list, status: :ok
  end

  private
 
  def post_params
    params.permit(:title, :body, :login, :ip)
  end
end
