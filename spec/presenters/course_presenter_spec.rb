require 'spec_helper'

RSpec.describe CoursePresenter do
  let(:course) { double(:course) }
  let(:event) { CoursePresenter.new(course) }

  it_behaves_like "Sanitized HTML", "description", "<br>", "alert" do
    let(:course) { Fabricate(:course, description: "<script>alert</script><br>")}
    let(:model) { event }
  end

  it '#venue' do
    expect(course).to receive(:sponsor)

    event.venue
  end

  it '#sponsors' do
    expect(course).to receive(:sponsor)

    event.sponsors
  end

  it '#admin_path' do
    expect(event.admin_path).to eq('#')
  end
end
