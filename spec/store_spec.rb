require 'spec_helper'

describe Store do
  let(:store) { Store.new }
  let(:url) { random_string }
  let(:tag) { random_string }

  describe "#add" do

    subject { store.add(url, tag) }

    before(:each) do
      @record = store.get(subject)
    end

    it "should be retrievable" do
      expect(@record).to_not be_nil
    end
    it "should have a created_at set" do
      expect(@record.created_at).to be_an_instance_of(Time)
    end
    it "should have a url set" do
      expect(@record.url).to eq(url)
    end

    context "url already added" do
      let(:new_tag) { random_string }

      it "should not add the url again" do
        expect{ store.add(url, new_tag) }.to_not change{ store.collection.count }
      end

      it "should return the existing id" do
        existing_id = store.collection.find_one({ 'url' => url })['id']
        expect(store.add(url, new_tag)).to eq(existing_id)
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
      expect(store.get(@id).clicks.first['ip']).to eq(params[:ip])
    end

  end
end