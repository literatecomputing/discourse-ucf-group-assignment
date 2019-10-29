require 'rails_helper'

describe discourse-group-assign-by-custom-field::ActionsController do
  before do
    Jobs.run_immediately!
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/discourse-group-assign-by-custom-field/list.json"
    expect(response.status).to eq(200)
  end
end
