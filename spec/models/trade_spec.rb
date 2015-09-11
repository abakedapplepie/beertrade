require 'rails_helper'

RSpec.describe Trade, type: :model do
  describe "#completed?" do
    let(:trade) { FactoryGirl.create(:trade, :completed) }

    subject { trade.completed? }


    it { is_expected.to be true }

    context "when waiting for approval" do
      let(:trade) { FactoryGirl.create(:trade, :waiting_for_approval) }
      it { is_expected.to be false }
    end
  end


  describe "#accepted?" do
    let(:trade) { FactoryGirl.create(:trade) }

    subject { trade.accepted? }


    it { is_expected.to be false }

    context "when completed" do
      let(:trade) { FactoryGirl.create(:trade, :completed) }
      it { is_expected.to be true }
    end

    context "when accepted" do
      let(:trade) { FactoryGirl.create(:trade, :accepted) }
      it { is_expected.to be true }
    end

    context "when waiting for approval" do
      let(:trade) { FactoryGirl.create(:trade, :waiting_for_approval) }
      it { is_expected.to be false }
    end
  end


  describe "#waiting_for_approval?" do
    let(:trade) { FactoryGirl.create(:trade, :completed) }
    let(:approver) { trade.participants.first.user }

    subject { trade.waiting_for_approval?(approver) }


    it { is_expected.to be false }

    context "when waiting for approval" do
      let(:trade) { FactoryGirl.create(:trade, :waiting_for_approval) }
      it { is_expected.to be true }
    end
  end


  describe "#waiting_to_give_feedback?" do
    let(:trade) { FactoryGirl.create(:trade, :accepted) }
    let(:waiting_for) { trade.participants.first.user }

    subject { trade.waiting_to_give_feedback?(waiting_for) }


    it { is_expected.to be true }

    context "with feedback from one participant" do
      let(:participant1) { trade.participants.first }
      let(:participant2) { participant1.other_participant }

      before do 
        participant1.update_attributes(feedback: "feedback", feedback_type: :positive) 
      end


      it "should only be true for participant1" do
        expect(trade.waiting_to_give_feedback?(participant1.user)).to be true
        expect(trade.waiting_to_give_feedback?(participant2.user)).to be false
      end
    end
  end


  describe "#can_delete?" do
    let(:trade) { FactoryGirl.create(:trade, :waiting_for_approval) }
    let(:pending_for) { trade.participants.first.user }

    subject { trade.can_delete?(pending_for) }

    it { is_expected.to be true }

    context "with the user that created it" do
      let(:pending_for) { trade.participants.second.user }
      it { is_expected.to be false }
    end
  end


  describe "#create_participants" do
    let(:trade) { FactoryGirl.build(:trade) }
    let(:requester) { FactoryGirl.create(:user) }
    let(:requestee) { FactoryGirl.create(:user) }
    
    pending # XXX will need to stub api calls
  end


  describe "#to_s" do
    let(:agreement) { nil }
    let(:trade) { FactoryGirl.create(:trade, :accepted, agreement: agreement) }
    let(:user1) { trade.participants.first.user }
    let(:user2) { trade.participants.second.user }

    subject { trade.to_s }

    it { is_expected.to eq "#{user1.username} and #{user2.username}" }

    context "with an agreement" do 
      let(:agreement) { "yinlins and stuff" }
      it { is_expected.to eq "#{user1.username} and #{user2.username}: #{agreement}" }
    end
  end
end
