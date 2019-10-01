require 'spec_helper'

RSpec.describe SponsorPresenter do
  let(:sponsor_presenter) { SponsorPresenter.new(sponsor)}

  context '#contact_full_name' do
    let(:sponsor) { double(:sponsor, contact_first_name: 'leonardo', contact_surname: 'da Vinci') }

    it 'should be stylised as camelcase' do
      expect(sponsor_presenter.contact_full_name).to eq('Leonardo Da Vinci')
    end
  end

  it_behaves_like "Sanitized HTML", "contact_info", "<br>", "alert" do
    let(:sponsor) { Fabricate(:sponsor, email: '<script>alert</script><br>') }
    let(:model) { SponsorPresenter.new(sponsor) }
  end
end
