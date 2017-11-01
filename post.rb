require 'sqlite3'

class Post

  @@SQLITE_DB_FILE = 'notepad.sqlite'

  def self.post_types
    {'Memo' => Memo, 'Link' => Link, 'Task' => Task}
  end

  def self.create(type)
    return post_types[type].new
  end

  def self.find(limit, type, id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)

    #1. конкретная запись
    if !id.nil?
      db.results_as_hash = true

      result = db.execute("SELECT * FROM posts WHERE rowid = ?", id)

      result = result[0] if result.is_a? Array

      if result.empty?
        puts "Такой id #{id} не найден в базе :("
        return nil
      else
        post = create(result['type'])

        post.load_data(result)

        return post
      end
    else
      # 2. вернуть таблицу записей
      db.results_as_hash = false

      query = "SELECT rowid, * FROM posts "
      query += "WHERE type = :type " unless type.nil?
      query += "ORDER by rowid DESC "
      query += "LIMIT :limit " unless limit.nil?

      statement = db.prepare(query)
      statement.bind_param('type', type) unless type.nil?
      statement.bind_param('limit', limit) unless limit.nil?

      result = statement.execute!
      statement.close
      db.close

      return result
    end
  end

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
    file = File.new(file_path, "w:UTF-8")

    for item in to_strings do
      file.puts(item)
    end

    file.close
  end

  def file_path
    carrent_path = File.dirname(__FILE__)
    file_name = @created_at.strftime("#{self.class.name}_%Y-%m-%d_%H-%M-%S.txt")
    return carrent_path + "/"+ file_name
  end

  def save_to_db
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = true
puts "INSERT INTO posts (" +
              to_db_hash.keys.join(',')+
              ")"+
              " VALUES ("+
              ('?,'*to_db_hash.keys.size).chomp(',')+
              ")"+
              to_db_hash.values.join(',')
    db.execute(
          "INSERT INTO posts (" +
              to_db_hash.keys.join(',')+
              ")"+
              " VALUES ("+
              ('?,'*to_db_hash.keys.size).chomp(',')+
              ")",
              to_db_hash.values
    )

    insert_row_id = db.last_insert_row_id

    db.close

    return insert_row_id
  end
  def to_db_hash
    {
        'type' => self.class.name,
        'created_at' => @created_at.to_s
    }
  end

  def load_data(data_hash)
    @created_at = Time.parse(data_hash['created_at'])
  end
end
