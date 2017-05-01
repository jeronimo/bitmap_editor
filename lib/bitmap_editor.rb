require 'pry'

module BitmapEditor
  class IO
    attr_accessor :errors, :raw, :lines
    def initialize
      @errors = []
    end

    def read_file(file = nil)
      return errors << "Please provide correct file" if file.nil? || !File.exists?(file)
      file = File.open(file)
      raw = file.read
      file.close
      raw
    end
  end

  class Errors
    attr_accessor :errors
  end

  class Parser
    attr_accessor :errors, :config, :source, :matrix, :output

    def initialize
      @config = {}
      @errors = []
      @matrix = []
      @output = ''
    end

    def parse(source = nil)
      @source = source
      check_for_errors
      return errors if errors.any?
      @source.split("\n").each do |line|
        parse_each_line(line)
      end
      matrix
    end

    def check_for_errors
      errors << '`S` command is missing' if !source.match('S')
      errors << '`I` command is missing' if !source.match('I')
      @matrix = errors if errors.any?
      @matrix
    end

    def parse_config(params)
      x, y = params[1].to_i, params[2].to_i
      return errors << '`I` command missing arguments' if params[1].nil? || params[2].nil?
      return errors << '`I` argument can\'t be 0' if x == 0 || y == 0
      return errors << '`I` argument can\'t be negative' if x < 0 || y < 0
      return errors << '`I` argument can\'t be higher than 250' if x > 250 || y > 250
      @config = {x: x, y: y}
    end

    def parse_dot(params)
      x, y, symbol = params[1].to_i, params[2].to_i, params[3]
      return errors << '`L` command missing arguments' if params[1].nil? || params[2].nil? || symbol.nil?
      return errors << '`L` argument can\'t be 0' if x == 0 || y == 0
      return errors << '`L` argument can\'t be negative' if x < 0 || y < 0
      return errors << '`L` arguments are outside bitmap' if x > config[:x] || y > config[:y]
      {x: x - 1, y: y - 1, symbol: symbol}
    end

    def parse_vertical(params)
      x, y1, y2, symbol = params[1].to_i, params[2].to_i, params[3].to_i, params[4]
      return errors << '`V` command missing arguments' if params[1].nil? || params[2].nil? || params[3].nil? || symbol.nil?
      return errors << '`V` argument can\'t be 0' if x == 0 || y1 == 0 || y2 == 0
      return errors << '`V` argument can\'t be negative' if x < 0 || y1 < 0 || y2 < 0
      return errors << '`V` arguments are outside bitmap' if x > config[:x] || y1 > config[:y] || y2 > config[:y]
      {x: x - 1, y1: y1 - 1, y2: y2 - 1, symbol: symbol}
    end

    def parse_horizontal(params)
      x1, x2, y, symbol = params[1].to_i, params[2].to_i, params[3].to_i, params[4]
      return errors << '`H` command missing arguments' if params[1].nil? || params[2].nil? || params[3].nil? || symbol.nil?
      return errors << '`H` argument can\'t be 0' if x1 == 0 || x2 == 0 || y == 0
      return errors << '`H` argument can\'t be negative' if x1 < 0 || x2 < 0 || y < 0
      return errors << '`H` arguments are outside bitmap' if x1 > config[:x] || x2 > config[:x] || y > config[:y]
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
      return errors if errors.any?
      draw_empty if matrix.empty?
      matrix[dot_config[:y]][dot_config[:x]] = dot_config[:symbol]
      matrix
    end

    def draw_vertical(params)
      vertical_config = parse_vertical(params)
      return errors if errors.any?
      draw_empty if matrix.empty?
      (vertical_config[:y1]..vertical_config[:y2]).each do |y|
        matrix[y][vertical_config[:x]] = vertical_config[:symbol]
      end
      matrix
    end

    def draw_horizontal(params)
      horizontal_config = parse_horizontal(params)
      return errors if errors.any?
      draw_empty if matrix.empty?
      (horizontal_config[:x1]..horizontal_config[:x2]).each do |x|
        matrix[horizontal_config[:y]][x] = horizontal_config[:symbol]
      end
      matrix
    end

    def serialize
      return errors if errors.any?
      o = []
      config[:y].times do |y|
        o << matrix[y].join + "\n"
      end if errors.empty?
      @output += o.join
    end

    def output
      return errors if errors.any?
      @output
    end

    def result
      matrix
    end

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

  end
end
