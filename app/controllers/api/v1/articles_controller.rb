class Api::V1::ArticlesController < Api::V1::BaseApiController
  def index
    articles = Article.order(updated_at: :desc)
    render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
  end

  def show
    article = Article.find(params[:id])
    render json: article, each_serializer: Api::V1::ArticleSerializer
  end

  def create
    article = current_user.articles.create!(article_params)
    render json: article, each_serializer: Api::V1::ArticleSerializer
  end

  def update
    article = current_user.articles.find(params[:id])
    article.update!(article_params)
    render json: article, each_serializer: Api::V1::ArticleSerializer
  end

  private

    def article_params
      params.require(:article).permit(:title, :body)
    end
end
