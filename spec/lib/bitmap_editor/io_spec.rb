# frozen_string_literal: true

require 'spec_helper'
require 'bitmap_editor/io'

describe BitmapEditor::IO do
  context 'Reading file' do
    it 'raises error message if there is no file' do
      expect { BitmapEditor::IO.new.read_file }
        .to raise_error 'Please provide correct file'
    end

    it 'raises error if `S` command is missing' do
      expect { BitmapEditor::IO.new.read_file('spec/examples/test.txt') }
        .to raise_error '`S` command is missing'
    end

    it 'raises error if `I` command is missing' do
      expect { BitmapEditor::IO.new.read_file('spec/examples/test_with_S.txt') }
        .to raise_error '`I` command is missing'
    end
  end
end
