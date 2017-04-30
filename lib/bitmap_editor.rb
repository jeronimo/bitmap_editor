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

      @source.split("\n").each do |line|
        parse_each_line(line)
      end
      result
    end

    def check_for_errors
      errors << 'Print out `S` command is missing' if !source.match('S')
      errors << 'Image width and height `I` command is missing' if !source.match('I')
      @result = errors if errors.any?
      @result
    end

    def parse_each_line(line = nil)
      params = line.strip.split

      case params[0]
      when 'I'
        @config = {x: params[1].to_i, y: params[2].to_i}
        config[:y].times do |y|
          result[y] = [] if result[y].nil?
          config[:x].to_i.times do |x|
            result[y][x] ='O'
          end
        end
      when 'C'
        config[:y].times do |y|
          result[y] = [] if result[y].nil?
          config[:x].to_i.times do |x|
            result[y][x] ='O'
          end
        end
      when 'L'
        line_config = {x: params[1].to_i - 1, y: params[2].to_i - 1, symbol: params[3] }
        result[line_config[:y]][line_config[:x]] = line_config[:symbol]
      when 'V'
        vertical = {x: params[1].to_i - 1, y1: params[2].to_i - 1, y2: params[3].to_i - 1, symbol: params[4] }
        (vertical[:y1]..vertical[:y2]).each do |y|
          result[y][vertical[:x]] = vertical[:symbol]
        end
      when 'H'
        horizontal = {x1: params[1].to_i - 1, x2: params[2].to_i - 1, y: params[3].to_i - 1, symbol: params[4] }
        (horizontal[:x1]..horizontal[:x2]).each do |x|
          result[horizontal[:y]][x] = horizontal[:symbol]
        end
      when 'S'
        printout = []
        config[:y].times do |y|
          printout << result[y].join + "\n"
        end
        puts printout.join
      end
      result
    end

  end
end
