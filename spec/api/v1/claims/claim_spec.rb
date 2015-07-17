require 'rails_helper'
require 'spec_helper'

describe API::V1::Advocates::Claim do
  include Rack::Test::Methods

  def app
    API::V1::Advocates::Claim
  end

  describe API::V1::Advocates::Claim do
    describe "POST /api/advocates/claims/validate" do

      let!(:current_advocate) { create(:advocate) }
      let!(:claim_params) { {:advocate_email => current_advocate.user.email, :case_type => 'trial', :case_number => '12345'} }

      it "returns 200 and String true for valid request" do
        post "/api/advocates/claims/validate", claim_params, format: :json
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("true")
      end

      it "returns an error when advocate email is invalid" do
        bad_claim_params = claim_params
        bad_claim_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
        post "/api/advocates/claims/validate", bad_claim_params, format: :json
        expect(last_response.status).to eq(400)
        error = JSON.parse(last_response.body)['error']
        expect(error).to eq("advocate_email is invalid")
      end

      it "returns an error when required param is missing" do
        claim_params.delete(:case_number)
        post "/api/advocates/claims/validate", claim_params, format: :json
        expect(last_response.status).to eq(400)
        error = JSON.parse(last_response.body)['error']
        expect(error).to eq("case_number is missing")
      end

    end

    describe "POST /api/advocates/claims" do

      let!(:current_advocate) { create(:advocate) }
      let!(:claim_params) { {:advocate_email => current_advocate.user.email, :case_type => 'trial', :case_number => '12345'} }

      it "returns 201, claim JSON and creates claim " do
        post "/api/advocates/claims", claim_params, format: :json
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)['id']).not_to be_nil
        expect{ post "/api/advocates/claims", claim_params, format: :json }.to change { Claim.count }.by(1)
      end

      it "returns an error when advocate email is invalid" do
        bad_claim_params = claim_params
        bad_claim_params[:advocate_email] = "non_existent_advocate@bigblackhole.com"
        post "/api/advocates/claims", bad_claim_params, format: :json
        expect(last_response.status).to eq(400)
        error = JSON.parse(last_response.body)['error']
        expect(error).to eq("advocate_email is invalid")
      end

      it "returns an error when required param is missing" do
        claim_params.delete(:case_number)
        post "/api/advocates/claims", claim_params, format: :json
        expect(last_response.status).to eq(400)
        error = JSON.parse(last_response.body)['error']
        expect(error).to eq("case_number is missing")
      end

    end

  end
end
