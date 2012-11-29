require 'spec_helper'
require 'active_support/core_ext'
require 'ostruct'
Rails = OpenStruct.new(env: OpenStruct.new(test?: true))
require 'solid/model_drop'

describe Solid::ModelDrop do
  describe "array methods" do

    it "work on a drop" do
      drop = described_class.new([1, 2, 3])
      drop.reverse.should be == [3, 2, 1]
    end

    it "go through #each" do
      klass = Class.new(described_class) do
        def each
          super.select(&:odd?)
        end
      end
      drop = klass.new([1, 2, 3])
      drop.reverse.should be == [3, 1]
    end

  end
end
