RSpec.shared_examples 'visitor viewing workshop actions' do
  scenario 'signing up or signing in' do
    expect(page).to have_content('Sign up')
    expect(page).to have_content('Log in')
  end
end
