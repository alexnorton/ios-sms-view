require 'sinatra/base'
require 'sinatra/activerecord'
require 'sqlite3'
require 'csv'
require_relative 'model'

class SMS < Sinatra::Base

  MOVING_AVERAGE_WINDOW = 3.days

  get '/' do
    p Message.last.handle['id']
    "#{Message.last.handle['id']} #{Message.last.text}"
  end

  get '/handles' do
    Handle.group(:id).to_json
  end

  get '/handles/:id' do
    handle =  Handle.find(params['id'])

    p handle

    handle.to_json(:include => { :messages => { :only => [:date, :text, :is_from_me] }})
  end

  get '/moving' do
    handles = {}

    Handle.all.each do |handle|
      messages = handle.messages

      if messages.count > 0
        start_date = messages.order(:date).first.date.to_date
        end_date = messages.order(:date).last.date.to_date

        results = []

        (start_date..end_date).each do |date|
          count = messages.where(date: ((date - MOVING_AVERAGE_WINDOW).to_db_timestamp)..((date + MOVING_AVERAGE_WINDOW).to_db_timestamp)).count

          results.push({:date => date, :count => count})
        end

        handles[handle.ROWID] = results

      end

    end
    handles.to_json
  end
end

class Date
  def to_db_timestamp
    self.to_time.to_i - Time.new(2001, 1, 1).to_i
  end
end