require 'spec_helper'

describe User, 'Validations' do
  it { should validate_uniqueness_of(:device_token) }
end

describe User, '#device_token' do
  context "when creating a user" do
    it "returns a unique value" do
      uuid = "unique-id"
      allow(SecureRandom).to receive(:uuid).and_return(uuid)

      user = User.create

      expect(user.device_token).to eq(uuid)
    end
  end

  context "when updating a user" do
    it "returns the same token" do
      user = User.create
      token = user.device_token

      user.save

      expect(user.device_token).to eq(token)
    end
  end
end
