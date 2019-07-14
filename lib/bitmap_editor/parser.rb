# frozen_string_literal: true

require './lib/bitmap_editor/praser_class_methods'

module BitmapEditor
  # Parser
  class Parser
    extend BitmapEditor::ParserClassMethods
    attr_accessor :config, :source, :matrix, :output

    def initialize(source = nil)
      @config = {}
      @source = source
      @matrix = []
      @output = ''
    end

    def parse
      source.each_line do |line|
        parse_each_line(line)
      end
      matrix
    end

    def parse_each_line(line = nil)
      params = line.strip.split

      case params[0]
      when 'I'
        @config = self.class.parse_config(params)
        @matrix = self.class.draw_empty(config)
      when 'C'
        @matrix = self.class.draw_empty(config)
      when 'L'
        @matrix = self.class.draw_dot(config, matrix, params)
      when 'V'
        @matrix = self.class.draw_vertical(config, matrix, params)
      when 'H'
        @matrix = self.class.draw_horizontal(config, matrix, params)
      when 'S'
        @output += self.class.serialize(config, matrix)
      end
    end

    def to_s
      output
    end
  end
end
