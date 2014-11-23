require 'sinatra/base'
require 'sinatra/activerecord'
require 'sqlite3'
require 'csv'
require_relative 'model'

MOVING_AVERAGE_WINDOW = 2.weeks

class Date
  def to_db_timestamp
    self.to_time.to_i - Time.new(2001, 1, 1).to_i
  end
end

handles = {}

CSV.open('public/sms.csv', 'w') do |csv|

  csv << ['key', 'value', 'date']

  start_date = Message.order(:date).first.date.to_date
  end_date = Message.order(:date).last.date.to_date

  Handle.all.each do |handle|
    messages = handle.messages

    if messages.count > 50

      results = []

      (start_date..end_date).step(14).each do |date|
        count = messages.where(date: ((date - MOVING_AVERAGE_WINDOW).to_db_timestamp)..((date + MOVING_AVERAGE_WINDOW).to_db_timestamp)).count

        results.push({:date => date, :count => count})

        csv << [handle.ROWID, count, date]
      end

      handles[handle.ROWID] = results

    end
  end

end