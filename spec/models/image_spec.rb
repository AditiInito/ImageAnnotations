require 'rails_helper'

RSpec.describe Image, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'validations' do
    it { should validate_presence_of(:picture) }
  end
  describe "Associations" do
    it { should have_many(:annotations).without_validating_presence }
  end
end
