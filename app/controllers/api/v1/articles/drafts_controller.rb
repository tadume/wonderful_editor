class Api::V1::Articles::DraftsController < Api::V1::BaseApiController
  before_action :authenticate_api_v1_user!, only: [:index, :show]
  def index
    articles = current_api_v1_user.articles.draft.order(updated_at: :desc)
    render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
  end

  def show
    article = current_api_v1_user.articles.draft.find(params[:id])
    render json: article, each_serializer: Api::V1::ArticleSerializer
  end
end
