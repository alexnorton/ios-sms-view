ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => 'sms.db'
)

class Message < ActiveRecord::Base
  self.table_name = 'message'
  self.inheritance_column = :_type_disabled

  def date
    Time.new(2001, 1, 1) + self.read_attribute(:date)
  end

  def is_from_me
    self.read_attribute(:is_from_me) == 1
  end

  belongs_to :handle
end

class Handle < ActiveRecord::Base
  self.table_name = 'handle'
  self.primary_key = 'ROWID'

  def id
    self.read_attribute(:id)
  end

  has_many :messages
end