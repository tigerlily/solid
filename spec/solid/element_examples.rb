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

  describe '.context_attribute' do

    let(:element) do
      described_class.context_attribute :current_user
      element = described_class.new('name', 'ARGUMENTS_STRING', ['{% endname %}'])
    end

    it 'should define a custom accessor to the rendered context' do
      element.stub(:current_context => {'current_user' => 'me'})
      element.current_user.should be == 'me'
    end

    it 'should raise a Solid::ContextError if called outside render' do
      expect{
        element.current_user
      }.to raise_error(Solid::ContextError)
    end

  end

  describe '#arguments' do

    it 'should instanciate a Solid::Arguments with his arguments_string' do
      Solid::Arguments.should_receive(:parse).with('ARGUMENTS_STRING')
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
