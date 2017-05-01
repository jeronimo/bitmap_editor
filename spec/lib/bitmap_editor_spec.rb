require 'spec_helper'
require 'bitmap_editor'

describe BitmapEditor::IO do
  context 'Reading file' do
    it 'raises error message if there is no file' do
      expect { BitmapEditor::IO.new.read_file }.to raise_error 'Please provide correct file'
    end

    it 'raises error if `S` command is missing' do
      expect { BitmapEditor::IO.new.read_file('spec/examples/test.txt') }.to raise_error '`S` command is missing'
    end

    it 'raises error if `I` command is missing' do
      expect { BitmapEditor::IO.new.read_file('spec/examples/test_with_S.txt') }.to raise_error '`I` command is missing'
    end
  end
end

describe BitmapEditor::Parser do
  subject { BitmapEditor::Parser.new }

  context '#parse_config' do
    it 'returns error if config is not full' do
      expect { subject.parse_config(['I']) }.to raise_error '`I` command missing arguments'
    end

    it 'returns error if arguments 0' do
      expect { subject.parse_config(['I', '3', '0']) }.to raise_error '`I` argument can\'t be 0'
    end

    it 'returns error if argument is negative' do
      expect { subject.parse_config(['I', '3', '-5']) }.to raise_error '`I` argument can\'t be negative'
    end

    it 'returns error if arguments are higher than 250' do
      expect { subject.parse_config(['I', '252', '251']) }.to raise_error '`I` argument can\'t be higher than 250'
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
      expect(subject.parse_dot(['C', '2', '2', 'C'])).to eq ({x: 1, y: 1, symbol: 'C'})
    end

    it 'inserts into matrix' do
      expect(subject.draw_dot(['L', '2', '2', 'C'])).to eq [['O', 'O'], ['O', 'C']]
    end

    it 'raises errors' do
      expect { subject.draw_dot(['L', '5', '1'])}.to raise_error '`L` command missing arguments'
      expect { subject.draw_dot(['L', '5', '0', 'C'])}.to raise_error '`L` argument can\'t be 0'
      expect { subject.draw_dot(['L', '-5', '5', 'C'])}.to raise_error '`L` argument can\'t be negative'
      expect { subject.draw_dot(['L', '2', '2', 'CC'])}.to raise_error '`L` symbol is too long'
      expect { subject.draw_dot(['L', '5', '5', 'C'])}.to raise_error '`L` arguments are outside bitmap'
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

    it 'raises errors' do
      expect { subject.draw_vertical(['V', '5', '5'])}.to raise_error '`V` command missing arguments'
      expect { subject.draw_vertical(['V', '5', '0', '3', 'V'])}.to raise_error '`V` argument can\'t be 0'
      expect { subject.draw_vertical(['V', '-5', '5', '3', 'V'])}.to raise_error '`V` argument can\'t be negative'
      expect { subject.draw_vertical(['V', '2', '1', '2', 'VV'])}.to raise_error '`V` symbol is too long'
      expect { subject.draw_vertical(['V', '2', '2', '1', 'V'])}.to raise_error '`V` y1 has to be lower than y2'
      expect { subject.draw_vertical(['V', '5', '5', '3', 'V'])}.to raise_error '`V` arguments are outside bitmap'
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

    it 'raises error' do
      expect { subject.draw_horizontal(['H', '5', '5'])}.to raise_error '`H` command missing arguments'
      expect { subject.draw_horizontal(['H', '5', '0', '3', 'H'])}.to raise_error '`H` argument can\'t be 0'
      expect { subject.draw_horizontal(['H', '-5', '5', '3', 'H'])}.to raise_error '`H` argument can\'t be negative'
      expect { subject.draw_horizontal(['H', '1', '2', '2', 'HH'])}.to raise_error '`H` symbol is too long'
      expect { subject.draw_horizontal(['H', '2', '1', '1', 'H'])}.to raise_error '`H` x1 has to be lower than x2'
      expect { subject.draw_horizontal(['H', '2', '1', '3', 'H'])}.to raise_error '`H` arguments are outside bitmap'
    end
  end

  it 'returns error message if there is no S command' do
    source = <<-eos
      I 1 2
    eos
    expect(subject.parse(source)).to eq [['O'], ['O']]
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
