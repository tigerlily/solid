shared_examples "a tag highjacker" do

  context 'tag highjacking' do

    let(:highjacked_tag_name) { described_class.tag_name.to_s }

    def highjacked_tag
      Liquid::Template.tags[highjacked_tag_name]
    end

    after :each do
      described_class.unload!
    end

    let!(:original_tag_id) { highjacked_tag.object_id }

    it 'should be able to replace original tag class' do
      expect{
        described_class.load!
      }.to change{ highjacked_tag.object_id }.from(original_tag_id).to(described_class.object_id)
    end

    it 'should be able to restore original tag class' do
      described_class.load!
      expect{
        described_class.unload!
      }.to change{ highjacked_tag.object_id }.from(described_class.object_id).to(original_tag_id)
    end

  end


end
