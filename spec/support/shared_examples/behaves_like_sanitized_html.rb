RSpec.shared_examples "Sanitized HTML" do |attribute, expected_html, expected_sanitize|
  it 'whitelists common html tags and attributes' do
    expect(model.send("#{attribute}")).to include(expected_html)
  end

  it 'sanitizes unsafe protocols' do
    expect(model.send("#{attribute}")).to_not match(/<script>/)
    expect(model.send("#{attribute}")).to include(expected_sanitize)
  end
end
