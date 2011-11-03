require 'solid'
shared_examples "a Solid element" do

  describe '.tag_name' do

    it 'should register tag to Liquid with given name' do
      Liquid::Template.should_receive(:register_tag).with('dummy', described_class)
      described_class.tag_name 'dummy'
    end

    it 'should return previously given name' do
      Liquid::Template.stub(:register_tag)
      described_class.tag_name 'dummy'
      described_class.tag_name.should be == 'dummy'
    end

  end

  describe '#arguments' do

    it 'should instanciate a Solid::Arguments with his arguments_string' do
      Solid::Arguments.should_receive(:new).with('ARGUMENTS_STRING')
      described_class.new('name', 'ARGUMENTS_STRING', ['{% endname %}'])
    end

    it 'should store his Solid:Arguments instance' do
      element = described_class.new('name', 'ARGUMENTS_STRING', ['{% endname %}'])
      element.arguments.should be_a(Solid::Arguments)
    end

  end

  describe '#display' do

    it 'should force developper to define it in child class' do
      element = described_class.new('name', 'ARGUMENTS_STRING', ['{% endname %}'])
      expect{
        element.display
      }.to raise_error(NotImplementedError)
    end

  end

end
