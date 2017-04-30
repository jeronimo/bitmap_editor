require 'spec_helper'
require 'bitmap_editor'

describe BitmapEditor::IO do
  context 'Reading file' do
    it 'returns error message if there is none' do
      expect(BitmapEditor::IO.new.read_file).to eq 'please provide correct file'
    end
  end
end

describe BitmapEditor::Parser do
  it 'returns parsed correct output' do
    content = <<-eos
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

    expect(BitmapEditor::Parser.parse(content)).to eq result
  end
end
