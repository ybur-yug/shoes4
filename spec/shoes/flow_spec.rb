require 'shoes/spec_helper'
require_relative 'helpers/fake_element'

describe Shoes::Flow do
  let(:app) { parent }
  let(:parent) { Shoes::App.new }
  let(:input_block) { Proc.new {} }
  let(:opts) { Hash.new }

  subject { Shoes::Flow.new(app, parent, opts, &input_block) }

  it_behaves_like "clickable object"
  it_behaves_like "hover and leave events"
  it_behaves_like "Slot"

  describe "initialize" do
    let(:opts) { {:width => 131, :height => 137} }
    it "sets accessors" do
      subject.parent.should == parent
      subject.width.should == 131
      subject.height.should == 137
      subject.blk.should == input_block
    end

    describe 'margins' do
      let(:opts){{margin: 143}}
      it 'sets the margins' do
        subject.margin.should == [143, 143, 143, 143]
      end
    end
  end

  it "sets default values" do
    f = Shoes::Flow.new(app, parent)
    f.width.should == app.width
    f.height.should == 0
  end

  it "clears with an optional block" do
    subject.should_receive(:clear).with(&input_block)
    subject.clear &input_block
  end

  describe "positioning" do
    it_behaves_like 'positioning through :_position'
    it_behaves_like 'positions the first element in the top left'

    shared_examples_for 'positioning in the same line' do
      it 'positions an element in the same row as long as they fit' do
        element2.absolute_top.should eq subject.absolute_top
      end

      it 'positions it next to the other element as long as it fits' do
        element2.absolute_left.should eq element.absolute_right + 1
      end

      it 'has a slot height of the maximum value of the 2 elements' do
        subject.height.should eq [element.height, element2.height].max
      end
    end

    describe 'two elements added' do
      include_context 'two slot children'
      include_context 'contents_alignment'

      it_behaves_like 'positioning in the same line'

      describe 'exact fit' do
        let(:opts) {{width: element.width + element2.width}}
        it_behaves_like 'positioning in the same line'
      end

    end

    describe 'when the elements dont fit next to each other' do
      let(:opts){ {width: element.width + 10} }
      it_behaves_like 'arranges elements underneath each other'
    end

    describe 'elements dont fit next to each other and set small height' do
      let(:opts){ {width: element.width + 10, height: element.height + 10} }
      it_behaves_like 'set height and contents alignment'
    end

    describe 'elements dont fit next to each other and set big height' do
      let(:opts){ {width: element.width + 10, height: 1000} }
      it_behaves_like 'set height and contents alignment'
    end

    describe 'with margins and two elements not fitting next to each other' do
      let(:opts){{width: element.width + 10, margin: 27}}
      it_behaves_like 'taking care of margin'
    end

  end
end
