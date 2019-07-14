# frozen_string_literal: true

require 'spec_helper'
require 'bitmap_editor'

describe 'Run executable file' do
  it 'returns parsed correct output' do
    result = <<~RESULT
      OOOOO
      OOZZZ
      AWOOO
      OWOOO
      OWOOO
      OWOOO
    RESULT

    expect(`bin/bitmap_editor spec/examples/simple.txt`).to eq result
  end

  it 'returns correct output with two `S` commands' do
    result = <<~RESULT
      OOO
      OOO
      AOO
      OOO
      OWO
      AWO
    RESULT

    expect(`bin/bitmap_editor spec/examples/double_s.txt`).to eq result
  end
end
