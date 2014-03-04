require 'spec_helper'

describe GenesisController do

  describe "GET 'balance'" do
    it "returns http success" do
      get 'balance'
      response.should be_success
    end
  end

end
