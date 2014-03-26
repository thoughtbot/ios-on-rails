require 'spec_helper'

describe Attendance, 'Validations' do
  it { should validate_presence_of(:event) }
  it { should validate_presence_of(:user) }

  it 'validates uniqueness of event_id and user_id' do
    event = create(:event)
    user = create(:user)
    create(:attendance, event: event, user: user)
    attendance = build(:attendance, event: event, user: user)

    expect(attendance).not_to be_valid
  end
end

describe Attendance, 'Associations' do
  it { should belong_to(:event) }
  it { should belong_to(:user) }
end
