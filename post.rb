class Post

  def initialize
    @created_at = Time.now
    @text = nil
  end

  def read_from_console
     # todo
  end

  def to_strings
    # todo
  end

  def save
    file = File.new(file_path, "w:UTF8")

    for item in to_strings do
      file.puts(item)
    end

    file.close
  end

  def file_path
    carrent_path = File.dirname(__FILE__)
    file_name = @created_at.srtftime("#{self.class.name}_%Y-%m-%d_%H-%M-%S.txt")
    return carrent_path + "/"+ filename
  end
end
