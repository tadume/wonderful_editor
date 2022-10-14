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
end
