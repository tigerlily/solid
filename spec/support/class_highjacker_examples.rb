shared_examples "a class highjacker" do

  context 'class highjacking' do

    let(:highjacked_class_name) { "Liquid::#{described_class.demodulized_name}" }

    def highjacked_class
      highjacked_class_name.split('::').inject(Object) { |klass, const_name| klass.const_get(const_name) }
    end

    after :each do
      described_class.unload!
    end

    let!(:original_class_id) { highjacked_class.object_id }

    it 'should be able to replace original class' do
      expect{
        described_class.load!
      }.to change{ highjacked_class.object_id }.from(original_class_id).to(described_class.object_id)
    end

    it 'should be able to restore original class' do
      described_class.load!
      expect{
        described_class.unload!
      }.to change{ highjacked_class.object_id }.from(described_class.object_id).to(original_class_id)
    end

  end


end
