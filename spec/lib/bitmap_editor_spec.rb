require 'spec_helper'
require 'bitmap_editor'

describe BitmapEditor::IO do
  context 'Reading file' do
    it 'returns error message if there is no file' do
      expect(BitmapEditor::IO.new.read_file).to eq ['Please provide correct file']
    end

    it 'returns string content' do
      expect(BitmapEditor::IO.new.read_file('spec/examples/test.txt')).to eq "any string\n"
    end
  end
end

describe BitmapEditor::Parser do
  subject { BitmapEditor::Parser.new }
  it 'returns error message if there is no S command' do
    source = <<-eos
      I 5 6
    eos
    expect(subject.parse(source)).to eq ['Print out `S` command is missing']
  end

  it 'returns error message if there is no I command' do
    source = <<-eos
      S
    eos
    expect(subject.parse(source)).to eq ['Image width and height `I` command is missing']
  end

  it 'returns parsed correct output' do
    source = <<-eos
      I 5 6
      L 1 3 A
      V 2 3 6 W
      H 3 5 2 Z
      S
    eos

    result = <<-eos
      OOOOO
      OOZZZ
      AWOOO
      OWOOO
      OWOOO
      OWOOO
    eos

    expect(subject.parse(source)).to eq result
  end
end
