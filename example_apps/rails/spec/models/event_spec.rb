require 'spec_helper'

describe Event, 'Validations' do
  it { should validate_presence_of(:lat) }
  it { should validate_presence_of(:lon) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:started_at) }
end

describe Event, 'Associations' do
  it { should have_many(:attendances) }
  it { should belong_to(:owner).class_name('User') }
  it { should have_many(:users).through(:attendances) }
end
