require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /index" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article) }
    it "記事の一覧が取得できる", :aggregate_failures do
      subject
      res = JSON.parse(response.body)
      # HTTPステータスコードが200である
      expect(response).to have_http_status(:ok)
      # 記事の個数は一致しているか
      expect(res.count).to eq 3
      # 返ってきた記事は、リクエスト通りか => それぞれのカラムを比較
      expect(res.map {|n| n["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      # 関連するuserもリクエスト通りのカラムか
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の article が存在する場合" do
      let(:article_id) { article.id }
      let(:article) { create(:article) }
      it "記事が取得できる", :aggregate_failures do
        subject
        res = JSON.parse(response.body)
        # ステータスコードが200である
        expect(response.status).to eq 200
        # 取得した記事が指定したものと一致している
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        # 関連する user も一致する
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
      end
    end

    context "指定した id の article が存在しない場合" do
      let(:article_id) { 100000 }
      it "記事が取得できない", :aggregate_failures do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /api/v1/articles/:id" do
    subject { post(api_v1_articles_path, params: params) }

    let(:params) { { article: attributes_for(:article) } }
    let(:current_user) { create(:user) }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    it "記事のレコードが作成される", :aggregate_failures do
      expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
      res = JSON.parse(response.body)
      expect(res["title"]).to eq params[:article][:title]
      expect(res["body"]).to eq params[:article][:body]
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params) }

    let(:params) { { article: attributes_for(:article) } }
    let(:current_user) { create(:user) }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    context "自身の記事を更新する場合" do
      let(:article) { create(:article, user: current_user) }
      it "記事が更新される", :aggregate_failures do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body])
        expect(response).to have_http_status(ok)
      end
    end

    context "自身の記事以外を更新する場合" do
      let!(:article) { create(:article, user: other_user) }
      let(:other_user) { create(:user) }
      it "記事の更新に失敗する", :aggregate_failures do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE /api/v1/articles/:id" do
    subject { delete(api_v1_article_path(article_id)) }

    let(:current_user) { create(:user) }
    let(:article_id) { article.id }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    context "自分の記事を選択する場合" do
      let!(:article) { create(:article, user: current_user) }
      it "記事を削除する", :aggregate_failures do
        expect { subject }.to change { Article.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "自分以外の記事を選択する場合" do
      let!(:article) { create(:article, user: other_user) }
      let(:other_user) { create(:user) }
      it "記事の削除に失敗する", :aggregate_failures do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
