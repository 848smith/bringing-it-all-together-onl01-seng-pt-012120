require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL 
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
        SQL
      DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
      SQL
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  
  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end
  
  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
      SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
end