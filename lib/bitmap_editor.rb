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
      lines = file.lines
      raw = file.read
      file.close
      raw
    end
  end

  class Parser
    attr_accessor :errors, :config, :source, :result

    def initialize
      @config = {}
      @errors = []
      @result = []
    end

    def parse(source = nil)
      @source = source
      check_for_errors
      return errors if errors.any?
      @source.split("\n").each do |line|
        parse_each_line(line)
      end
      result
    end

    def check_for_errors
      errors << 'Print out `S` command is missing' if !source.match('S')
      errors << '`I` command is missing' if !source.match('I')
      @result = errors if errors.any?
      @result
    end

    def set_config(params)
      x, y = params[1].to_i, params[2].to_i
      return errors << '`I` command missing arguments' if params[1].nil? || params[2].nil?
      return errors << '`I` argument can\'t be 0' if x == 0 || y == 0
      return errors << '`I` argument can\'t be negative' if x < 0 || y < 0
      @config = {x: x, y: y}
    end

    def get_dot_config(params)
      x, y, symbol = params[1].to_i, params[2].to_i, params[3]
      return errors << '`L` command missing arguments' if params[1].nil? || params[2].nil? || symbol.nil?
      return errors << '`L` argument can\'t be 0' if x == 0 || y == 0
      return errors << '`L` argument can\'t be negative' if x < 0 || y < 0
      {x: x - 1, y: y - 1, symbol: symbol}
    end

    def get_vertical_config(params)
      x, y1, y2, symbol = params[1].to_i, params[2].to_i, params[3].to_i, params[4]
      return errors << '`V` command missing arguments' if params[1].nil? || params[2].nil? || params[3].nil? || symbol.nil?
      return errors << '`V` argument can\'t be 0' if x == 0 || y1 == 0 || y2 == 0
      return errors << '`V` argument can\'t be negative' if x < 0 || y1 < 0 || y2 < 0
      {x: x - 1, y1: y1 - 1, y2: y2 - 1, symbol: symbol}
    end

    def get_horizontal_config(params)
      x1, x2, y, symbol = params[1].to_i, params[2].to_i, params[3].to_i, params[4]
      return errors << '`H` command missing arguments' if params[1].nil? || params[2].nil? || params[3].nil? || symbol.nil?
      return errors << '`H` argument can\'t be 0' if x1 == 0 || x2 == 0 || y == 0
      return errors << '`H` argument can\'t be negative' if x1 < 0 || x2 < 0 || y < 0
      {x1: x1 - 1, x2: x2 - 1, y: y - 1, symbol: symbol}
    end

    def draw_empty
      output = []
      config[:y].times do |y|
        output[y] = [] if output[y].nil?
        config[:x].to_i.times do |x|
          output[y][x] ='O'
        end
      end
      @result = output
      output
    end

    def draw_dot(params)
      dot_config = get_dot_config(params)
      return errors if errors.any?
      draw_empty if result.empty?
      result[dot_config[:y]][dot_config[:x]] = dot_config[:symbol]
      result
    end

    def draw_vertical(params)
      vertical_config = get_vertical_config(params)
      return errors if errors.any?
      draw_empty if result.empty?
      (vertical_config[:y1]..vertical_config[:y2]).each do |y|
        result[y][vertical_config[:x]] = vertical_config[:symbol]
      end
      result
    end

    def draw_horizontal(params)
      horizontal_config = get_horizontal_config(params)
      return errors if errors.any?
      draw_empty if result.empty?
      (horizontal_config[:x1]..horizontal_config[:x2]).each do |x|
        result[horizontal_config[:y]][x] = horizontal_config[:symbol]
      end
      result
    end

    def output
      return errors if errors.any?
      o = []
      config[:y].times do |y|
        o << result[y].join + "\n"
      end if errors.empty?
      o.join
    end

    def parse_each_line(line = nil)
      params = line.strip.split

      case params[0]
      when 'I'
        set_config(params)
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
        output
      end
    end

  end
end
