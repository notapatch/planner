require 'spec_helper'

RSpec.describe AddressPresenter do
  let(:address) { Fabricate.build(:address) }
  let(:presenter) { AddressPresenter.new(address) }
  let(:bad_address) { Fabricate.build(:address, flat: "BEG<script>alert('owned');</script>END<br>") }
  let(:bad_presenter) { AddressPresenter.new(bad_address) }

  context 'with #to_html' do
    it 'outputs address as html' do
      html_address = "#{address.flat}<br>#{address.street}<br>#{address.city}, #{address.postal_code}"

      expect(presenter.to_html).to eq(html_address)
    end

    it_behaves_like "Sanitized HTML", "to_html", "<br>", "alert('owned');" do
      let(:model) { bad_presenter }
    end
  end


  context 'with #to_s' do
    it 'outputs address as comma delimitated string' do
      expect(presenter.to_s).to eq("#{address.flat}, #{address.street}, #{address.city}, #{address.postal_code}")
    end

    it 'does not sanitize unsafe protocols' do
      expect(bad_presenter.to_s).to include("<script>alert('owned');</script>")
    end
  end
end
