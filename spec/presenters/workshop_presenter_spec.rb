require 'spec_helper'

describe WorkshopPresenter do
  let(:invitations) { [Fabricate(:student_workshop_invitation),
                       Fabricate(:student_workshop_invitation),
                       Fabricate(:coach_workshop_invitation),
                       Fabricate(:coach_workshop_invitation)
                      ] }

  let(:chapter) { Fabricate(:chapter) }
  let(:organiser) { chapter.organisers.first }
  let(:workshop_double) { double(:workshop, attendances: invitations, host: Fabricate(:sponsor), chapter: chapter) }
  let(:workshop) { WorkshopPresenter.new(workshop_double) }
  let(:coach_invite) { Fabricate(:coach_workshop_invitation) }
  let(:student_invite) { Fabricate(:student_workshop_invitation) }

  it '#venue' do
    expect(workshop_double).to receive(:host)

    workshop.venue
  end

  it '#organisers' do
    expect(workshop_double).to receive(:permissions)
    expect(workshop_double).to receive(:chapter).and_return(chapter)

    workshop.organisers
  end

  it '#time' do
    expect(workshop_double).to receive(:time).and_return(Time.zone.now)

    workshop.time
  end

  context 'with #attendees_csv' do
    it 'skips header on request' do
      presenter = described_class.new(instance_double('Workshop', attendances: [], chapter: chapter))
      allow(presenter).to receive(:organisers).at_least(:once).and_return []

      csv = presenter.attendees_csv(headers: false)

      expect(csv.lines.count).to eq(0)
    end

    it 'adds header on request' do
      presenter = described_class.new(instance_double('Workshop', attendances: [], chapter: chapter))
      allow(presenter).to receive(:organisers).at_least(:once).and_return []

      csv = presenter.attendees_csv(headers: true)

      expect(csv.lines.count).to eq(1)
      expect(csv).to include('full_name', 'role', 'about_you', 'first_time')
    end

    it 'returns expected fields about each member' do
      presenter = described_class.new(instance_double('Workshop', attendances: [student_invite], chapter: chapter))
      allow(presenter).to receive(:organisers).at_least(:once).and_return []

      csv = presenter.attendees_csv(headers: false)

      expect(csv.lines.count).to eq(1)
      expect(csv).to include(student_invite.member.full_name, 'STUDENT', student_invite.member.about_you, 'true')
    end

    it 'attends student member as student' do
      presenter = described_class.new(instance_double('Workshop', attendances: [student_invite], chapter: chapter))
      allow(presenter).to receive(:organisers).at_least(:once).and_return []

      csv = presenter.attendees_csv(headers: false)

      expect(csv).to include('STUDENT')
    end

    it 'attends coach member as coach' do
      presenter = described_class.new(instance_double('Workshop', attendances: [coach_invite], chapter: chapter))
      allow(presenter).to receive(:organisers).at_least(:once).and_return []

      csv = presenter.attendees_csv(headers: false)

      expect(csv).to include('COACH')
    end

    it 'attends organising member as organiser' do
      presenter = described_class.new(instance_double('Workshop', attendances: [], chapter: chapter))
      allow(presenter).to receive(:organisers).at_least(:once).and_return [organiser]

      csv = presenter.attendees_csv(headers: false)

      expect(csv.lines.count).to eq(1)
      expect(csv).to include('ORGANISER')
    end

    it 'attends coach/organiser member as organiser' do
      invitation = Fabricate(:coach_workshop_invitation, member: organiser)
      presenter = described_class.new(instance_double('Workshop', attendances: [invitation], chapter: chapter))
      allow(presenter).to receive(:organisers).at_least(:once).and_return [organiser]

      csv = presenter.attendees_csv(headers: false)

      expect(csv.lines.count).to eq(1)
      expect(csv).to include('ORGANISER')
    end

    it 'orders attendees by role' do
      presenter = described_class.new(instance_double('Workshop', attendances: [student_invite, coach_invite], chapter: chapter))
      allow(presenter).to receive(:organisers).at_least(:once).and_return [organiser]

      csv = presenter.attendees_csv(headers: false)

      expect(csv.lines.count).to eq(3)
      expect(csv.lines[0]).to include('ORGANISER')
      expect(csv.lines[1]).to include('COACH')
      expect(csv.lines[2]).to include('STUDENT')
    end

    it 'orders attendees within role by full name' do
      organisers = [Fabricate(:member, name: 'ZZZ'), Fabricate(:member, name: 'AAA')]
      invitations = [Fabricate(:coach_workshop_invitation, member: Fabricate(:member, name: 'ZZZ')),
                     Fabricate(:student_workshop_invitation, member: Fabricate(:member, name: 'ZZZ')),
                     Fabricate(:coach_workshop_invitation, member: Fabricate(:member, name: 'AAA')),
                     Fabricate(:student_workshop_invitation, member: Fabricate(:member, name: 'AAA'))]

      presenter = described_class.new(instance_double('Workshop', attendances: invitations, chapter: chapter))
      allow(presenter).to receive(:organisers).at_least(:once).and_return organisers

      csv = presenter.attendees_csv(headers: false)

      expect(csv.lines.count).to eq(6)
      expect(csv.lines[0]).to include('ORGANISER', 'AAA')
      expect(csv.lines[1]).to include('ORGANISER', 'ZZZ')
      expect(csv.lines[2]).to include('COACH', 'AAA')
      expect(csv.lines[3]).to include('COACH', 'ZZZ')
      expect(csv.lines[4]).to include('STUDENT', 'AAA')
      expect(csv.lines[5]).to include('STUDENT', 'ZZZ')
    end
  end

  it '#attendees_emails' do
    workshop = Fabricate(:workshop)
    presenter = WorkshopPresenter.new(workshop)
    members = Fabricate.times(6, :member)
    members.each_with_index do |member, index|
      index % 2 == 0 ? Fabricate(:attending_workshop_invitation, member: member,  workshop: workshop) :
                       Fabricate(:attending_workshop_invitation, member: member,  workshop: workshop, role: 'Coach')
    end

    expect(presenter.attendees_emails.split(', ')).to match_array(members.map(&:email))
  end
end
