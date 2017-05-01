require 'pry'

module BitmapEditor
  class Error < StandardError
    # Cleanup backtrace to look error messages more nice
    def backtrace
      ''
    end
  end

  class Errors
    class << self
      def check_file(file)
        raise BitmapEditor::Error, "Please provide correct file" if file.nil? || !File.exists?(file)
      end

      def check_file_content(content)
        raise BitmapEditor::Error, '`S` command is missing' if !content.match('S')
        raise BitmapEditor::Error, '`I` command is missing' if !content.match('I')
      end

      def check_config(params)
        x, y = params[1].to_i, params[2].to_i
        raise BitmapEditor::Error, '`I` command missing arguments' if params[1].nil? || params[2].nil?
        raise BitmapEditor::Error, '`I` argument can\'t be 0' if x == 0 || y == 0
        raise BitmapEditor::Error, '`I` argument can\'t be negative' if x < 0 || y < 0
        raise BitmapEditor::Error, '`I` argument can\'t be higher than 250' if x > 250 || y > 250
      end

      def check_dot(params, config)
        x, y = params[1].to_i, params[2].to_i
        raise BitmapEditor::Error, '`L` command missing arguments' if params[1].nil? || params[2].nil? || params[3].nil?
        raise BitmapEditor::Error, '`L` argument can\'t be 0' if x == 0 || y == 0
        raise BitmapEditor::Error, '`L` argument can\'t be negative' if x < 0 || y < 0
        raise BitmapEditor::Error, '`L` arguments are outside bitmap' if x > config[:x] || y > config[:y]
        raise BitmapEditor::Error, '`L` symbol is too long' if params[3].length > 1
      end

      def check_vertical(params, config)
        x, y1, y2 = params[1].to_i, params[2].to_i, params[3].to_i
        raise BitmapEditor::Error, '`V` command missing arguments' if params[1].nil? || params[2].nil? || params[3].nil? || params[4].nil?
        raise BitmapEditor::Error, '`V` argument can\'t be 0' if x == 0 || y1 == 0 || y2 == 0
        raise BitmapEditor::Error, '`V` argument can\'t be negative' if x < 0 || y1 < 0 || y2 < 0
        raise BitmapEditor::Error, '`V` arguments are outside bitmap' if x > config[:x] || y1 > config[:y] || y2 > config[:y]
        raise BitmapEditor::Error, '`V` y1 has to be lower than y2' if y1 > y2
        raise BitmapEditor::Error, '`V` symbol is too long' if params[4].length > 1
      end

      def check_horizontal(params, config)
        x1, x2, y = params[1].to_i, params[2].to_i, params[3].to_i
        raise BitmapEditor::Error, '`H` command missing arguments' if params[1].nil? || params[2].nil? || params[3].nil? || params[4].nil?
        raise BitmapEditor::Error, '`H` argument can\'t be 0' if x1 == 0 || x2 == 0 || y == 0
        raise BitmapEditor::Error, '`H` argument can\'t be negative' if x1 < 0 || x2 < 0 || y < 0
        raise BitmapEditor::Error, '`H` arguments are outside bitmap' if x1 > config[:x] || x2 > config[:x] || y > config[:y]
        raise BitmapEditor::Error, '`H` x1 has to be lower than x2' if x1 > x2
        raise BitmapEditor::Error, '`H` symbol is too long' if params[4].length > 1
      end
    end
  end

  class IO
    def read_file(file = nil)
      BitmapEditor::Errors.check_file(file)
      file = File.open(file)
      content = file.read
      BitmapEditor::Errors.check_file_content(content)
      file.close
      content
    end
  end

  class Parser
    attr_accessor :config, :source, :matrix, :output

    def initialize
      @config = {}
      @matrix = []
      @output = ''
    end

    def parse(source = nil)
      @source = source
      @source.each_line do |line|
        parse_each_line(line)
      end
      matrix
    end

    def output
      @output
    end

    # PRIVATE - These methods should go as private but left out as examples for testing

    def parse_each_line(line = nil)
      params = line.strip.split

      case params[0]
      when 'I'
        parse_config(params)
        draw_empty
      when 'C'
        draw_empty
      when 'L'
        draw_dot(params)
      when 'V'
        draw_vertical(params)
      when 'H'
        draw_horizontal(params)
      when 'S'
        serialize
      end
    end

    def parse_config(params)
      x, y = params[1].to_i, params[2].to_i
      BitmapEditor::Errors.check_config(params)
      @config = {x: x, y: y}
    end

    def parse_dot(params)
      x, y, symbol = params[1].to_i, params[2].to_i, params[3]
      BitmapEditor::Errors.check_dot(params, config)
      {x: x - 1, y: y - 1, symbol: symbol}
    end

    def parse_vertical(params)
      x, y1, y2, symbol = params[1].to_i, params[2].to_i, params[3].to_i, params[4]
      BitmapEditor::Errors.check_vertical(params, config)
      {x: x - 1, y1: y1 - 1, y2: y2 - 1, symbol: symbol}
    end

    def parse_horizontal(params)
      x1, x2, y, symbol = params[1].to_i, params[2].to_i, params[3].to_i, params[4]
      BitmapEditor::Errors.check_horizontal(params, config)
      {x1: x1 - 1, x2: x2 - 1, y: y - 1, symbol: symbol}
    end

    def draw_empty
      empty = []
      config[:y].times do |y|
        empty[y] = [] if empty[y].nil?
        config[:x].to_i.times do |x|
          empty[y][x] ='O'
        end
      end
      @matrix = empty
    end

    def draw_dot(params)
      dot_config = parse_dot(params)
      draw_empty if matrix.empty?
      matrix[dot_config[:y]][dot_config[:x]] = dot_config[:symbol]
      matrix
    end

    def draw_vertical(params)
      vertical_config = parse_vertical(params)
      draw_empty if matrix.empty?
      (vertical_config[:y1]..vertical_config[:y2]).each do |y|
        matrix[y][vertical_config[:x]] = vertical_config[:symbol]
      end
      matrix
    end

    def draw_horizontal(params)
      horizontal_config = parse_horizontal(params)
      draw_empty if matrix.empty?
      (horizontal_config[:x1]..horizontal_config[:x2]).each do |x|
        matrix[horizontal_config[:y]][x] = horizontal_config[:symbol]
      end
      matrix
    end

    def serialize
      @output += config[:y].times.map{ |y| matrix[y].join + "\n" }.join
    end
  end
end
