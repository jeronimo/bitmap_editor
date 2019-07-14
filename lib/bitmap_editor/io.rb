# frozen_string_literal: true

module BitmapEditor
  # IO
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
end
