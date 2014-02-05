require 'spec_helper'

describe Store do
  let(:store) { Store.new }
  let(:id) { random_string }
  let(:url) { random_string }
  let(:tag) { random_string }

  describe "#add" do

    subject { store.add(id, url, tag) }

    it "should be retrievable" do
      subject
      store.get(id).should_not be_nil
    end
    context "when already added id" do
      before(:each) do
        store.add(id, random_string)
      end
      it "should raise DuplicateIdError" do
        expect { subject }.to raise_error(Store::DuplicateIdError)
      end
    end
  end

  describe "#track" do
    let(:at) { Time.now.utc }
    let(:ip_address) { "23.46.12.35" }

    before(:each) do
      store.add(id, random_string)
    end

    subject { store.track(id, at, ip_address) }

    it "should increment the click count" do
      expect { subject }.to change { store.get(id).click_count }.by(1)
    end

  end
end