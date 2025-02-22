class Api::PostsController < ApplicationController
  def create
    user = User.find_or_create_by(login: post_params[:login])
    post = user.posts.build(post_params.except(:login))

    if post.save
      render json: { post: PostSerializer.new(post), user: UserSerializer.new(user) }, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def top_posts
    top_posts = Post.top_posts_by_avg_rating(params[:limit] || 10)

    render json: top_posts, each_serializer: PostSerializer, status: :ok
  rescue ArgumentError => e
    logger.error("Invalid limit parameter: #{e.message}")
    render json: { errors: "Invalid limit parameter" }, status: :unprocessable_entity
  end

  def ips
    ips_list = Post.ips_posted_by_diff_authors
    formatted_ips_list = format_ips_list(ips_list)

    render json: formatted_ips_list, status: :ok
  end

  private

  def post_params
    params.permit(:title, :body, :login, :ip)
  end

  def format_ips_list(ips_list)
    grouped_ips = {}
    ips_list.each do |post|
      grouped_ips[post.ip] ||= []
      grouped_ips[post.ip] << post.login
    end

    grouped_ips.map do |ip, authors|
      { ip: ip, authors: authors }
    end
  end
end
