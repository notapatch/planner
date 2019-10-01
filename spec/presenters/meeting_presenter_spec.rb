require 'spec_helper'

RSpec.describe MeetingPresenter do
  let(:meeting) { Fabricate(:meeting) }
  let(:event) { MeetingPresenter.new(meeting) }

  it '#sponsors' do
    expect(event.sponsors).to eq([])
  end

  it '#description' do
    expect(event.description).to eq(meeting.description)
  end

  context '#description' do
    it 'returns string' do
      expect(event.description).to eq(meeting.description)
    end

    it_behaves_like "Sanitized HTML", "description", "<br>", "alert" do
      let(:model) { MeetingPresenter.new(Fabricate(:meeting, description: '<script>alert</script><br>')) }
    end
  end

  it '#venue' do
    expect(event.venue).to eq(meeting.venue)
  end

  it '#organisers' do
    permissions = Fabricate(:permission, resource: meeting, name: 'organiser')

    expect(event.organisers).to eq(permissions.members)
  end

  it '#attendees_emails' do
    attendees = Fabricate.times(4, :attending_meeting_invitation, meeting: meeting)

    expect(event.attendees_emails).to eq(attendees.map(&:member).map(&:email).join(', '))
  end

  it '#to_s' do
    expect(event.to_s).to eq(meeting.name)
  end

  it '#admin_path' do
    expect(event.admin_path).to eq(Rails.application.routes.url_helpers.admin_meeting_path(meeting))
  end
end
