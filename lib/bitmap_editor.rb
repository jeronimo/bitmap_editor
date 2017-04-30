module BitmapEditor
  class IO
    def read_file(file = nil)
      return "please provide correct file" if file.nil? || !File.exists?(file)

      # File.open(file).each do |line|
      #   line = line.chomp
      #   case line
      #   when 'S'
      #     puts "There is no image"
      #   else
      #     puts 'unrecognised command :('
      #   end
      # end
    end
  end

  class Parser
    def self.parse(content = nil)
      content
    end
  end
end
