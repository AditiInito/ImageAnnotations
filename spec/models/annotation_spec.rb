require 'rails_helper'

RSpec.describe Annotation, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  subject {
    Annotation.new(key: "key", value: "value", image_id: 4)
  }
  describe "Validations" do
    it "is valid with empty key" do
      subject.key=nil
      expect(subject).to_not be_valid
    end
    it "is valid with empty value" do
      subject.value=nil
      expect(subject).to_not be_valid
    end
  end
  describe "Associations" do
    it { should belong_to(:image).without_validating_presence }
  end
end
