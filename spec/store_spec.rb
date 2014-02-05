require 'spec_helper'

describe Store do
  let(:store) { Store.new }
  let(:url) { random_string }
  let(:tag) { random_string }

  describe "#add" do

    subject { store.add(url, tag) }

    it "should be retrievable" do
      store.get(subject).should_not be_nil
    end
    context "when already added url" do
      before(:each) do
        @id = subject
      end
      it "should raise return the same id" do
        subject.should eq(@id)
      end
    end
  end

  describe "#track" do
    let(:at) { Time.now.utc }
    let(:params) { { :ip => "23.46.12.35" } }

    before(:each) do
      @id = store.add(random_string)
    end

    subject { store.track(@id, at, params) }

    it "should increment the click count" do
      expect { subject }.to change { store.get(@id).click_count }.by(1)
    end
    it "should add the params to the record" do
      subject
      store.get(@id).clicks.first['ip'].should eq(params[:ip])
    end

  end
end