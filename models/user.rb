# User class
require 'yaml'

class User
  attr_reader :name

  def initialize(name, password)
    users_data = YAML.load_file(File.expand_path("../../users.yml", __FILE__))
    @name = name
    File.write(users_data, [:name] = password)
  end
end

User.new('bill', '10')
