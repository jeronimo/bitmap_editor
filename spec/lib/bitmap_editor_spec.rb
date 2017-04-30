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

  context 'set_config' do
    it 'returns error if config is not full' do
      subject.set_config(['I'])
      expect(subject.errors).to include '`I` command missing arguments'
    end

    it 'returns error if arguments 0' do
      subject.set_config(['I', '3', '0'])
      expect(subject.errors).to include '`I` argument can\'t be 0'
    end

    it 'returns error if argument is negative' do
      subject.set_config(['I', '3', '-5'])
      expect(subject.errors).to include '`I` argument can\'t be negative'
    end

    it 'returns config' do
      subject.set_config(['I', '3', '5'])
      expect(subject.config).to eq ({x: 3, y: 5})
    end

    it 'returns correct config if too many arguments' do
      subject.set_config(['I', '3', '5', '9'])
      expect(subject.config).to eq ({x: 3, y: 5})
    end
  end

  context '#draw_empty' do
    it 'draws empty bitmap' do
      subject.config = {x: 2, y: 2}
      expect(subject.draw_empty).to eq [['O', 'O'], ['O', 'O']]
    end
  end

  context 'Dot' do
    it 'gets dot config' do
      dot_line = ['C', '2', '2', 'C']
      expect(subject.get_dot_config(dot_line)).to eq ({x: 1, y: 1, symbol: 'C'})
    end

    it 'inserts dot' do
      subject.config = {x: 2, y: 2}
      dot_line = ['L', '2', '2', 'C']
      expect(subject.draw_dot(dot_line)).to eq [['O', 'O'], ['O', 'C']]
    end
  end

  context 'vertical line' do
    it 'gets vertical config' do
      vertical_line = ['V', '1', '1', '2', 'V']
      expect(subject.get_vertical_config(vertical_line)).to eq ({x: 0, y1: 0, y2: 1, symbol: 'V'})
    end
    it 'inserts vertical' do
      subject.config = {x: 2, y: 2}
      vertical_line = ['V', '1', '1', '2', 'V']
      expect(subject.draw_vertical(vertical_line)).to eq [['V', 'O'], ['V', 'O']]
    end
  end

  context 'horizontal line' do
    it 'gets vertical config' do
      horizontal_line = ['H', '1', '2', '2', 'H']
      expect(subject.get_horizontal_config(horizontal_line)).to eq ({x1: 0, x2: 1, y: 1, symbol: 'H'})
    end
    it 'inserts vertical' do
      subject.config = {x: 2, y: 2}
      horizontal_line = ['H', '1', '2', '2', 'H']
      expect(subject.draw_horizontal(horizontal_line)).to eq [['O', 'O'], ['H', 'H']]
    end
  end

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
    expect(subject.parse(source)).to eq ['`I` command is missing']
  end

  it 'returns all error messages on empty file' do
    source = <<-eos
    eos
    expect(subject.parse(source)).to eq ['Print out `S` command is missing', '`I` command is missing']
  end

  it 'returns parsed correct output' do
    source = <<-eos
      I 5 6
      L 1 3 A
      V 2 3 6 W
      H 3 5 2 Z
      S
    eos

    result = <<~EOS
      OOOOO
      OOZZZ
      AWOOO
      OWOOO
      OWOOO
      OWOOO
    EOS
    subject.parse(source)
    expect(subject.output).to eq result
  end
end
