# frozen_string_literal: true

require 'spec_helper'
require 'bitmap_editor'

describe BitmapEditor::Parser do
  subject { BitmapEditor::Parser }

  context '.parse_config' do
    it 'returns error if config is not full' do
      expect { subject.parse_config(['I']) }
        .to raise_error '`I` command missing arguments'
    end

    it 'returns error if arguments 0' do
      expect { subject.parse_config(%w[I 3 0]) }
        .to raise_error '`I` argument can\'t be 0'
    end

    it 'returns error if argument is negative' do
      expect { subject.parse_config(%w[I 3 -5]) }
        .to raise_error '`I` argument can\'t be negative'
    end

    it 'returns error if arguments are higher than 250' do
      expect { subject.parse_config(%w[I 252 251]) }
        .to raise_error '`I` argument can\'t be higher than 250'
    end

    it 'returns config' do
      expect(subject.parse_config(%w[I 3 5])).to eq(x: 3, y: 5)
    end

    it 'returns correct config if too many arguments' do
      expect(subject.parse_config(%w[I 3 5 9])).to eq(x: 3, y: 5)
    end
  end

  context '.draw_empty' do
    it 'draws empty bitmap' do
      expect(subject.draw_empty(x: 2, y: 2)).to eq [%w[O O], %w[O O]]
    end
  end

  context 'Dot' do
    let(:config) { { x: 2, y: 2 } }

    it 'gets dot config' do
      expect(subject.parse_dot(config, %w[C 2 2 C]))
        .to eq(x: 1, y: 1, symbol: 'C')
    end

    it 'inserts into matrix' do
      expect(subject.draw_dot(config, [], %w[L 2 2 C]))
        .to eq([%w[O O], %w[O C]])
    end

    it 'raises errors' do
      expect { subject.draw_dot(config, [], %w[L 5 1]) }
        .to raise_error '`L` command missing arguments'
      expect { subject.draw_dot(config, [], %w[L 5 0 C]) }
        .to raise_error '`L` argument can\'t be 0'
      expect { subject.draw_dot(config, [], %w[L -5 5 C]) }
        .to raise_error '`L` argument can\'t be negative'
      expect { subject.draw_dot(config, [], %w[L 2 2 CC]) }
        .to raise_error '`L` symbol is too long'
      expect { subject.draw_dot(config, [], %w[L 5 5 C]) }
        .to raise_error '`L` arguments are outside bitmap'
    end
  end

  context 'Vertical line' do
    let(:config) { { x: 2, y: 2 } }
    let(:vertical_line) { %w[V 1 1 2 V] }

    it 'gets config' do
      expect(subject.parse_vertical(config, vertical_line))
        .to eq(x: 0, y1: 0, y2: 1, symbol: 'V')
    end

    it 'inserts into matrix' do
      expect(subject.draw_vertical(config, [], vertical_line))
        .to eq [%w[V O], %w[V O]]
    end

    it 'raises errors' do
      expect { subject.draw_vertical(config, [], %w[V 5 5]) }
        .to raise_error '`V` command missing arguments'
      expect { subject.draw_vertical(config, [], %w[V 5 0 3 V]) }
        .to raise_error '`V` argument can\'t be 0'
      expect { subject.draw_vertical(config, [], %w[V -5 5 3 V]) }
        .to raise_error '`V` argument can\'t be negative'
      expect { subject.draw_vertical(config, [], %w[V 2 1 2 VV]) }
        .to raise_error '`V` symbol is too long'
      expect { subject.draw_vertical(config, [], %w[V 2 2 1 V]) }
        .to raise_error '`V` y1 has to be lower than y2'
      expect { subject.draw_vertical(config, [], %w[V 5 5 3 V]) }
        .to raise_error '`V` arguments are outside bitmap'
    end
  end

  context 'Horizontal line' do
    let(:config) { { x: 2, y: 2 } }
    let(:horizontal_line) { %w[H 1 2 2 H] }

    it 'gets horizontal config' do
      expect(subject.parse_horizontal(config, horizontal_line))
        .to eq(x1: 0, x2: 1, y: 1, symbol: 'H')
    end

    it 'inserts into matrix' do
      expect(subject.draw_horizontal(config, [], horizontal_line))
        .to eq [%w[O O], %w[H H]]
    end

    it 'raises error' do
      expect { subject.draw_horizontal(config, [], %w[H 5 5]) }
        .to raise_error '`H` command missing arguments'
      expect { subject.draw_horizontal(config, [], %w[H 5 0 3' H]) }
        .to raise_error '`H` argument can\'t be 0'
      expect { subject.draw_horizontal(config, [], %w[H -5 5 3' H]) }
        .to raise_error '`H` argument can\'t be negative'
      expect { subject.draw_horizontal(config, [], %w[H 1 2 2' HH]) }
        .to raise_error '`H` symbol is too long'
      expect { subject.draw_horizontal(config, [], %w[H 2 1 1' H]) }
        .to raise_error '`H` x1 has to be lower than x2'
      expect { subject.draw_horizontal(config, [], %w[H 2 1 3' H]) }
        .to raise_error '`H` arguments are outside bitmap'
    end
  end

  it 'returns error message if there is no S command' do
    source = <<-NOSCOMMAND
      I 1 2
    NOSCOMMAND

    expect(subject.new(source).parse).to eq [%w[O], %w[O]]
  end

  it '#serialize array matrix into string' do
    result = <<~MATRIXINTOSTRING
      XQA
      OBA
    MATRIXINTOSTRING

    expect(subject.serialize({ x: 3, y: 2 }, [%w[X Q A], %w[O B A]]))
      .to eq result
  end
end
