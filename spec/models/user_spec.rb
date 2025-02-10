require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:posts) }
    it { should have_many(:ratings) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:login) }
    it { should validate_uniqueness_of(:login) }
  end
end
