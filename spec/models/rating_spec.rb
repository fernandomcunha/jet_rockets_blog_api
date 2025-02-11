require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

  describe 'validations' do
    it { should validate_inclusion_of(:value).in_range(1..5).with_message("must be between 1 and 5") }

    context 'validates uniqueness of user_id scoped to post_id' do
      let(:user) { create(:user) }
      let(:post) { create(:post, user:) }

      subject { build(:rating, user: user, post: post, value: 3) }

      it { should validate_uniqueness_of(:user_id).scoped_to(:post_id).with_message("can rate a post only once") }
    end
  end
end
