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

    it "should return a shortened url with a 7 digit" do
      @id.length.should eq(7)
    end
    it "should be possible to retrieve the url from the store" do
      store.get(@id).url.should eq(url)
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
      store.get(@id).clicks[0]['ip'].should eq(params[:ip])
      store.get(@id).clicks[0]['user_agent'].should eq(params[:user_agent])
    end
  end
end