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

  context '#parse_config' do
    it 'returns error if config is not full' do
      subject.parse_config(['I'])
      expect(subject.output).to include '`I` command missing arguments'
    end

    it 'returns error if arguments 0' do
      subject.parse_config(['I', '3', '0'])
      expect(subject.output).to include '`I` argument can\'t be 0'
    end

    it 'returns error if argument is negative' do
      subject.parse_config(['I', '3', '-5'])
      expect(subject.output).to include '`I` argument can\'t be negative'
    end

    it 'returns error if arguments are higher than 250' do
      subject.parse_config(['I', '252', '251'])
      expect(subject.output).to include '`I` argument can\'t be higher than 250'
    end

    it 'returns config' do
      subject.parse_config(['I', '3', '5'])
      expect(subject.config).to eq ({x: 3, y: 5})
    end

    it 'returns correct config if too many arguments' do
      subject.parse_config(['I', '3', '5', '9'])
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
    before do
      subject.config = {x: 2, y: 2}
    end

    it 'gets dot config' do
      dot_line = ['C', '2', '2', 'C']
      expect(subject.parse_dot(dot_line)).to eq ({x: 1, y: 1, symbol: 'C'})
    end

    it 'inserts into matrix' do
      dot_line = ['L', '2', '2', 'C']
      expect(subject.draw_dot(dot_line)).to eq [['O', 'O'], ['O', 'C']]
    end

    it 'returns error if command coordinates are too high' do
      dot_line = ['L', '5', '5', 'C']
      expect(subject.draw_dot(dot_line)).to include '`L` arguments are outside bitmap'
    end
  end

  context 'Vertical line' do
    before do
      subject.config = {x: 2, y: 2}
    end

    it 'gets config' do
      vertical_line = ['V', '1', '1', '2', 'V']
      expect(subject.parse_vertical(vertical_line)).to eq ({x: 0, y1: 0, y2: 1, symbol: 'V'})
    end

    it 'inserts into matrix' do
      vertical_line = ['V', '1', '1', '2', 'V']
      expect(subject.draw_vertical(vertical_line)).to eq [['V', 'O'], ['V', 'O']]
    end

    it 'returns error if command coordinates are too high' do
      vertical_line = ['V', '1', '4', '5', 'V']
      expect(subject.draw_vertical(vertical_line)).to include '`V` arguments are outside bitmap'
      expect(subject.errors).to include '`V` arguments are outside bitmap'
    end
  end

  context 'Horizontal line' do
    before do
      subject.config = {x: 2, y: 2}
    end

    it 'gets horizontal config' do
      horizontal_line = ['H', '1', '2', '2', 'H']
      expect(subject.parse_horizontal(horizontal_line)).to eq ({x1: 0, x2: 1, y: 1, symbol: 'H'})
    end
    it 'inserts into matrix' do
      horizontal_line = ['H', '1', '2', '2', 'H']
      expect(subject.draw_horizontal(horizontal_line)).to eq [['O', 'O'], ['H', 'H']]
    end

    it 'returns error if command coordinates are too high' do
      horizontal_line = ['H', '1', '4', '5', 'H']
      expect(subject.draw_horizontal(horizontal_line)).to include '`H` arguments are outside bitmap'
    end
  end

  it 'returns error message if there is no S command' do
    source = <<-eos
      I 5 6
    eos
    expect(subject.parse(source)).to eq ['`S` command is missing']
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
    expect(subject.parse(source)).to eq ['`S` command is missing', '`I` command is missing']
  end

  it '#serialize array matrix into string' do
    subject.config = {x: 3, y: 2}
    subject.matrix = [['X', 'Q', 'A'], ['O', 'B', 'A']]
    result = <<~EOS
        XQA
        OBA
      EOS
    expect(subject.serialize).to eq result
  end

  context '#parse' do
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

    it 'returns correct output with two `S` commands' do
      source = <<-eos
        I 3 3
        L 1 3 A
        S
        V 2 2 3 W
        S
      eos

      result = <<~EOS
        OOO
        OOO
        AOO
        OOO
        OWO
        AWO
      EOS
      subject.parse(source)
      expect(subject.output).to eq result
    end
  end
end
