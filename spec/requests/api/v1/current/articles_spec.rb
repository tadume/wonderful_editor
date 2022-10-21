require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  let(:headers) { current_user.create_new_auth_token }
  let(:current_user) { create(:user) }
  describe "GET /api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    context "公開状態の記事が存在する場合" do
      let!(:article1) { create(:article, :published, user: current_user, updated_at: 1.day.ago) }
      let!(:article2) { create(:article, :published, user: current_user, updated_at: 5.day.ago) }
      let!(:article3) { create(:article, :published, user: current_user) }
      it "記事が取得できる", :aggregate_failures do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res.length).to eq 3
        expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
        expect(res[0]["id"]).to eq article3.id
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["client"]).to be_present
      end
    end
  end
end
