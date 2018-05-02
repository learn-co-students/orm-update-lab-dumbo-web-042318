require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade 
  attr_reader :id 
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id=nil,name,grade)
    @id = id 
    @name = name 
    @grade = grade
  end

  def self.table
    return "#{self.name.downcase}s"
  end
  def self.create_table
    sql = "CREATE TABLE #{self.table} (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT);"
    DB[:conn].execute(sql)
  
  end

  def self.drop_table
    sql = "DROP TABLE #{self.table}"
    DB[:conn].execute(sql)
  end

  def save
    if self.id.nil?
      sql = "INSERT INTO #{self.class.table} (name,grade) VALUES
        (?,?);"
      DB[:conn].execute(sql, self.name, self.grade)
    sql = "SELECT last_insert_rowid() FROM #{self.class.table}"
    @id = DB[:conn].execute(sql)[0][0]
    else 
      self.update
    end
  end

  def update 
    sql = "UPDATE #{self.class.table}
      SET name = ?, grade = ?
      WHERE id = ?;"
    DB[:conn].execute(sql,self.name,self.grade,self.id)
  end

  def self.create(name,grade)
    student = self.new(name,grade)
    student.save 
  end

  def self.new_from_db(row)
    student = self.new(row[0],row[1],row[2]) 
  end

  def self.find_by_name(name)
    sql = "SELECT *
      FROM #{self.table}
      WHERE name = ?;"
    self.new_from_db(DB[:conn].execute(sql,name)[0])
  end

end
