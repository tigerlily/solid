require 'spec_helper'

describe Solid::Template do

  let(:liquid) { %{first_string{% comment %}
      {% if foo %}ifcontent{% endif %}
      {% if foo %}ifsecondcontent{% endif %}
    {% endcomment %}
    {% unless foo %}unlesscontent{% endunless %}
    
  } }

  let(:template) { Solid::Template.parse(liquid) }

  specify { subject.should be_an(Enumerable) }

  describe '#each' do

    let(:yielded_nodes) do
      [].tap do |nodes|
        template.each{ |node| nodes << node }
      end
     end

     let(:yielded_classes) { yielded_nodes.map(&:class) }

    it 'should yield parent nodes before child nodes' do
      yielded_classes.index(Liquid::Comment).should be < yielded_classes.index(Liquid::If)
    end

    it 'should yield first sibling first (No ! really ? ...)' do
      yielded_classes.index(Liquid::Comment).should be < yielded_classes.index(Liquid::Unless)
    end

  end

end
