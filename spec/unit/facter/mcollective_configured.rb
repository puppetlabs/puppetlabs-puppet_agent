require 'spec_helper'

describe 'mcollective_configured fact' do
  [true, false].each do |mco|
    context "server.cfg exists? #{mco}" do
      before(:each) { File.expects(:exists?).with(/server\.cfg/).returns mco }
      subject { Facter.fact(:mcollective_configured).value }
      after(:each) { Facter.clear }

      describe "should return #{mco}" do
        it { is_expected.to eq(mco) }
      end
    end
  end
end
