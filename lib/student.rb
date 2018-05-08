require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection
  # anywhere in this class
  # with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade 
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
  
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"

    DB[:conn].execute(sql)
  end

  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      # binding.pry
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      self.update
    end

  end

  def self.create(name, grade)
    Student.new(name, grade).save
  end

  def self.new_from_db(row)
    new_student = Student.new(row[1],row[2],row[0])
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE students 
      SET grade = ?, name = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.grade, self.name, self.id)
  end
end

