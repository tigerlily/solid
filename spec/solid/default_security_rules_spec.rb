require 'spec_helper'

describe Solid, 'default security rules' do

  describe 'Hash instances' do
    subject { {} }

    it { should safely_respond_to :sort }

  end

end
