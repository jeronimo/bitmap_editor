require 'pry'

module BitmapEditor
  class IO
    attr_accessor :errors
    def initialize
      @errors = []
    end

    def read_file(file = nil)
      return errors << "Please provide correct file" if file.nil? || !File.exists?(file)
      file = File.open(file)
      content = file.read
      file.close
      content
    end
  end

  class Parser
    attr_accessor :errors, :source, :result

    def initialize
      @errors = []
    end

    def parse(source = nil)
      @source = source
      check_for_errors
      @result
    end

    def check_for_errors
      errors << 'Print out `S` command is missing' if !source.match('S')
      errors << 'Image width and height `I` command is missing' if !source.match('I')
      @result = errors if errors.any?
      @result
    end
  end
end
