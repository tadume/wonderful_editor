require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  let(:headers) { current_user.create_new_auth_token }
  let(:current_user) { create(:user) }
  describe "GET /api/v1/articles/drafts" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    context "ログインユーザーの下書き記事が存在している場合" do
      let!(:article1) { create(:article, :draft, user: current_user) }
      let!(:article2) { create(:article, :draft) }
      it "下書き記事の一覧を取得できる", :aggregate_failures do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res[0]["id"]).to eq article1.id
        expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      end
    end
  end

  describe "GET /api/v1/articles/drafts/:id" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    context "指定した記事が存在していて" do
      let(:article_id) { article.id }
      context "自分の下書き記事だった場合" do
        let(:article) { create(:article, :draft, user: current_user) }
        it "下書き記事を取得できる", :aggregate_failures do
          subject
          res = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(res["id"]).to eq article.id
          expect(res.keys).to eq ["id", "title", "body", "user_id", "created_at", "updated_at", "status"]
          expect(res["user_id"]).to eq article.user.id
          header = response.header
          expect(header["access-token"]).to be_present
          expect(header["client"]).to be_present
          expect(header["expiry"]).to be_present
          expect(header["uid"]).to be_present
        end
      end

      context "自分以外の記事だった場合" do
        let!(:article) { create(:article, :draft) }
        it "記事が取得できない" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
