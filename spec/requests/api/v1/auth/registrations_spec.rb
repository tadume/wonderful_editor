require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "必要な情報が存在するとき" do
      let(:params) { attributes_for(:user) }
      it "ユーザーの新規登録ができる", :aggregate_failures do
        # Userの数は一つ増える
        expect { subject }.to change { User.count }.by(1)
        # 最後に登録したuser のカラムが一致している
        res = JSON.parse(response.body)
        expect(res["data"]["email"]).to eq(User.last.email)
        # ステータスコードが正常である
        expect(response).to have_http_status(:ok)
      end

      it "header 情報が取得できる", :aggregate_failures do
        # それぞれのheaderが存在する
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["uid"]).to be_present
      end
    end

    context "name が存在しない時" do
      let(:params) { attributes_for(:user, name: nil) }
      it "エラーする", :aggregate_failures do
        # Userの数は変わらない
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        # name がからである
        expect(res["errors"]["name"]).to include "can't be blank"
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "email が存在しない時" do
      let(:params) { attributes_for(:user, email: nil) }
      it "エラーする", :aggregate_failures do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]["email"]).to include "can't be blank"
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "password が存在しない時" do
      let(:params) { attributes_for(:user, password: nil) }
      it "エラーする", :aggregate_failures do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]["password"]).to include "can't be blank"
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
