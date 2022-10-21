class Api::V1::Current::ArticlesController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:index]
  def index
    articles = current_api_v1_user.articles.published.order(updated_at: :desc)
    render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
  end
end
