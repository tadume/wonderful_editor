# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :string           default("draft")
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  describe "正常系" do
    context "タイトルと内容が入力されている時" do
      let(:article) { create(:article) }
      it "下書き状態の記事が作成される", :aggregate_failures do
        expect(article).to be_valid
        expect(article.status).to eq "draft"
      end
    end

    context "status が下書き状態の時" do
      let(:article) { create(:article, :draft) }
      it "下書きの記事が作成できる", :aggregate_failures do
        expect(article).to be_valid
        expect(article.status).to eq "draft"
      end
    end

    context "status が公開状態の時" do
      let(:article) { create(:article, :published) }
      it "公開の記事が作成できる", :aggregate_failures do
        expect(article).to be_valid
        expect(article.status).to eq "published"
      end
    end
  end
end
