require_relative "../config/environment.rb"

class Student

  attr_reader :id
  attr_accessor :name, :grade

  def initialize(name:, grade:, id: nil) 
    @name = name,
    @grade = grade,
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
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
    if(self.id != nil)
      self.update
    else
      sql = "INSERT INTO students(name, grade) VALUES(?,?)"
      DB[:conn].execute(sql, self.name, self.grade)

      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def self.create(name, grade)
    newStudent = Student.new(name, grade)
    newStudent.save
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, grade FROM students WHERE name =?
    SQL

    Student.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE students SET grade = ?, name = ? WHERE id =?
    SQL
    DB[:conn].execute(sql, self.grade, self.name, self.id)
  end
  
end
