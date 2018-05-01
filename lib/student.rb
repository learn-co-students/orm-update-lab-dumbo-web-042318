require_relative "../config/environment.rb"
require 'pry'
# Remember, you can access your database connection anywhere in this class
#  with DB[:conn]

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.table_name
    self.name.downcase + 's'
  end

  def self.create_table

    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS #{table_name} (id INTEGER, name TEXT, grade TEXT)
      SQL
    DB[:conn].execute(sql)
#------------------------
    # sql = <<-SQL
    # CREATE TABLE IF NOT EXISTS ? (ID INTEGER, name TEXT, grade TEXT)
    #   SQL
    # DB[:conn].execute(sql,table_name)
# binding.pry
  end
  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS #{table_name}
      SQL
      DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE #{self.class.table_name} SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = Student.new(name,grade)
    student.save
  end

  def self.find_by_name(name)
    sql = "select * from #{table_name} where name = ?"
  stud = DB[:conn].execute(sql, name)[0]
  new_from_db(stud)
  end

  def self.new_from_db(row)
    # sql = "SELECT * FROM #{self.table_name}"
    # arr = DB[:conn].execute(sql)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  def save
    if self.id==nil
      sql2 = <<-SQL
        INSERT INTO #{self.class.table_name} (name, grade)
        VALUES (?,?)
        SQL
        DB[:conn].execute(sql2, self.name, self.grade)

        sql = "SELECT last_insert_rowid() FROM #{self.class.table_name} LIMIT 1"
        id = DB[:conn].execute(sql)[0][0]
        @id = id
    else
      self.update
    end
  end

end
