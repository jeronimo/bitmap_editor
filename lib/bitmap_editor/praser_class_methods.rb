# frozen_string_literal: true

module BitmapEditor
  # class methods used for BitmapEditor::Parser
  module ParserClassMethods
    def parse_config(params)
      x = params[1].to_i
      y = params[2].to_i
      BitmapEditor::Errors.check_config(params)
      { x: x, y: y }
    end

    def parse_dot(config, params)
      x = params[1].to_i
      y = params[2].to_i
      symbol = params[3]
      BitmapEditor::Errors.check_dot(config, params)
      { x: x - 1, y: y - 1, symbol: symbol }
    end

    def parse_vertical(config, params)
      BitmapEditor::Errors.check_vertical(config, params)
      {
        x: params[1].to_i - 1,
        y1: params[2].to_i - 1,
        y2: params[3].to_i - 1,
        symbol: params[4]
      }
    end

    def parse_horizontal(config, params)
      BitmapEditor::Errors.check_horizontal(config, params)
      {
        x1: params[1].to_i - 1,
        x2: params[2].to_i - 1,
        y: params[3].to_i - 1,
        symbol: params[4]
      }
    end

    def draw_empty(config)
      empty = []
      config[:y].times do |y|
        empty[y] = [] if empty[y].nil?
        config[:x].to_i.times do |x|
          empty[y][x] = 'O'
        end
      end
      empty
    end

    def draw_dot(config, matrix, params)
      dot_config = parse_dot(config, params)
      matrix = draw_empty(config) if matrix.empty?
      matrix[dot_config[:y]][dot_config[:x]] = dot_config[:symbol]
      matrix
    end

    def draw_vertical(config, matrix, params)
      vertical_config = parse_vertical(config, params)
      matrix = draw_empty(config) if matrix.empty?
      (vertical_config[:y1]..vertical_config[:y2]).each do |y|
        matrix[y][vertical_config[:x]] = vertical_config[:symbol]
      end
      matrix
    end

    def draw_horizontal(config, matrix, params)
      horizontal_config = parse_horizontal(config, params)
      matrix = draw_empty(config) if matrix.empty?
      (horizontal_config[:x1]..horizontal_config[:x2]).each do |x|
        matrix[horizontal_config[:y]][x] = horizontal_config[:symbol]
      end
      matrix
    end

    def serialize(config, matrix)
      config[:y].times.map { |y| matrix[y].join + "\n" }.join
    end
  end
end
