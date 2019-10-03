require 'spec_helper'

RSpec.describe ChapterPresenter do
  let(:chapter) { Fabricate(:chapter_without_organisers) }
  let(:presenter) { ChapterPresenter.new(chapter) }

  context '#email' do
    it 'allows email addresses' do
      expect(presenter.email).to eq(chapter.email)
    end

    it 'escapes html' do
      presenter = ChapterPresenter.new(Fabricate(:chapter_without_organisers, email: '<BR>'))
      expect(presenter.email).to eq('&lt;BR&gt;')
    end
  end

  it '#twitter_id' do
    expect(chapter).to receive(:twitter_id)

    presenter.twitter_id
  end

  it '#twitter_handle' do
    expect(chapter).to receive(:twitter)

    presenter.twitter
  end

  it '#upcoming_workshops' do
    Fabricate.times(2, :past_workshop, chapter: chapter)
    workshops = Fabricate.times(3, :workshop, chapter: chapter,
                                              date_and_time: Time.zone.now + 1.week)

    expect(presenter.upcoming_workshops).to match_array(workshops)
  end

  it '#organisers' do
    permissions = Fabricate(:permission, resource: chapter, name: 'organiser')

    expect(presenter.organisers).to match_array(permissions.members)
  end
end
