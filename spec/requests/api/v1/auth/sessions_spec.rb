require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST /api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "登録されたユーザーがログインするとき" do
      let(:params) { attributes_for(:user, email: user.email, password: user.password) }
      let!(:user) { create(:user) }
      it "ログインに成功する", :aggregate_failures do
        subject
        expect(response).to have_http_status(:ok)
        # ヘッダー情報を取得できる
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
      end
    end

    context "email が一致しないとき" do
      let(:params) { attributes_for(:user, email: user.email) }
      let(:user) { create(:user) }
      it "ログインに失敗する", :aggregate_failures do
        subject
        expect(response).to have_http_status(:unauthorized)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
      end
    end

    context "password が一致しないとき" do
      let(:params) { attributes_for(:user, password: user.password) }
      let(:user) { create(:user) }
      it "ログインに失敗する", :aggregate_failures do
        subject
        expect(response).to have_http_status(:unauthorized)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
      end
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "適切な情報を送信する場合", :aggregate_failures do
      let(:headers) { user.create_new_auth_token }
      let!(:user) { create(:user) }
      it "ログアウトできる" do
        # ログアウトしたので　token がなくなる
        subject
        expect(response.header).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    context "不適切な情報を送信する場合", :aggregate_failures do
      let(:headers) { { "access-token" => "" } }
      let(:user) { create(:user) }
      it "ログアウトに失敗する", :aggregate_failures do
        subject
        expect(response).to have_http_status(:not_found)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "User was not found or was not logged in."
      end
    end
  end
end
