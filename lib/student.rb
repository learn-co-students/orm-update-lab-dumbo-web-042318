require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade

  # instance methods

  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end

  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO #{self.class.table_name} (name, grade)
        VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
    else
      sql = <<-SQL
        UPDATE #{self.class.table_name}
        SET name = ?, grade = ?
        WHERE id = ?;
      SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

    def update
      sql = <<-SQL
        UPDATE #{self.class.table_name}
        SET name = ?, grade = ?
        WHERE id = ?;
      SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end


  end


  # Class methods

  def self.table_name
    "#{self.name.downcase}s"
  end

  def self.create_table
    sql = <<-SQL
            CREATE TABLE IF NOT EXISTS #{table_name} (
              id INTEGER PRIMARY KEY,
              name TEXT,
              grade TEXT
            );
            SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"

    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE name = ?;
    SQL

    row = DB[:conn].execute(sql, name)[0]

    new_from_db(row)
  end

end
