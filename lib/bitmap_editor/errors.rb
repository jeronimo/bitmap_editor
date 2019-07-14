# frozen_string_literal: true

module BitmapEditor
  # Error
  class Error < StandardError
    # TODO, Cleanup backtrace to look error messages more nice
    def backtrace
      ''
    end
  end

  # Errors
  class Errors
    class << self
      def check_file(file)
        raise BitmapEditor::Error, 'Please provide correct file' if
          file.nil? || !File.exist?(file)
      end

      def check_file_content(content)
        raise BitmapEditor::Error, '`S` command is missing' unless
          content.match('S')
        raise BitmapEditor::Error, '`I` command is missing' unless
          content.match('I')
      end

      def check_config(params)
        x = params[1].to_i
        y = params[2].to_i
        raise BitmapEditor::Error, '`I` command missing arguments' if
          params[1].nil? || params[2].nil?
        raise BitmapEditor::Error, '`I` argument can\'t be 0' if
          x.zero? || y.zero?
        raise BitmapEditor::Error, '`I` argument can\'t be negative' if
          x.negative? || y.negative?
        raise BitmapEditor::Error, '`I` argument can\'t be higher than 250' if
          x > 250 || y > 250
      end

      def check_dot(config, params)
        x = params[1].to_i
        y = params[2].to_i
        raise BitmapEditor::Error, '`L` command missing arguments' if
          params[1].nil? || params[2].nil? || params[3].nil?
        raise BitmapEditor::Error, '`L` argument can\'t be 0' if
          x.zero? || y.zero?
        raise BitmapEditor::Error, '`L` argument can\'t be negative' if
          x.negative? || y.negative?
        raise BitmapEditor::Error, '`L` arguments are outside bitmap' if
          x > config[:x] || y > config[:y]
        raise BitmapEditor::Error, '`L` symbol is too long' if
          params[3].length > 1
      end

      def check_vertical(config, params)
        x = params[1].to_i
        y1 = params[2].to_i
        y2 = params[3].to_i
        raise BitmapEditor::Error, '`V` command missing arguments' if
          params[1].nil? || params[2].nil? || params[3].nil? || params[4].nil?
        raise BitmapEditor::Error, '`V` argument can\'t be 0' if
          x.zero? || y1.zero? || y2.zero?
        raise BitmapEditor::Error, '`V` argument can\'t be negative' if
          x.negative? || y1.negative? || y2.negative?
        raise BitmapEditor::Error, '`V` arguments are outside bitmap' if
          x > config[:x] || y1 > config[:y] || y2 > config[:y]
        raise BitmapEditor::Error, '`V` y1 has to be lower than y2' if
          y1 > y2
        raise BitmapEditor::Error, '`V` symbol is too long' if
          params[4].length > 1
      end

      def check_horizontal(config, params)
        x1 = params[1].to_i
        x2 = params[2].to_i
        y = params[3].to_i
        raise BitmapEditor::Error, '`H` command missing arguments' if
          params[1].nil? || params[2].nil? || params[3].nil? || params[4].nil?
        raise BitmapEditor::Error, '`H` argument can\'t be 0' if
          x1.zero? || x2.zero? || y.zero?
        raise BitmapEditor::Error, '`H` argument can\'t be negative' if
          x1.negative? || x2.negative? || y.negative?
        raise BitmapEditor::Error, '`H` arguments are outside bitmap' if
          x1 > config[:x] || x2 > config[:x] || y > config[:y]
        raise BitmapEditor::Error, '`H` x1 has to be lower than x2' if
          x1 > x2
        raise BitmapEditor::Error, '`H` symbol is too long' if
          params[4].length > 1
      end
    end
  end
end
