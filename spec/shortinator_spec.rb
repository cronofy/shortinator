require 'spec_helper'

describe Shortinator do

  let(:store) { Shortinator::Store.new }
  let(:url) { "http://#{random_string}.com/#{random_string}?#{random_string}=#{random_string}" }

  describe ".shorten" do

    subject { Shortinator.shorten(url) }

    before(:each) do
      @shortened_url = subject
      @id = @shortened_url.gsub("#{Shortinator.host}/", '')
    end

    it "should return a shortened url with id that matches regex" do
      expect(@id).to match(Shortinator::KEY_REGEX)
    end
    it "should be possible to retrieve the url from the store" do
      expect(store.get(@id).url).to eq(url)
    end

  end

  describe ".click" do

    let(:params) { { :ip => "123.45.2.56", :user_agent => "Chrome" } }

    before(:each) do
      @id = store.add(url)
    end

    subject { Shortinator.click(@id, params) }

    it "records the click in the store" do
      subject
      expect(store.get(@id).clicks[0]['ip']).to eq(params[:ip])
      expect(store.get(@id).clicks[0]['user_agent']).to eq(params[:user_agent])
    end
  end
end