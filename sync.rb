require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'open-uri'
require 'csv'

class Azumio
  @@url = "https://api.azumio.com/"

  def initialize()
    @agent = Mechanize.new
  end

  def login(email, password)
    login_page = @agent.get(@@url)

    return true if is_logged_in?
    login_page.forms.first.fields.select{|f| f.name=='email'}.first.value = email
    login_page.forms.first.fields.select{|f| f.name=='password'}.first.value = password

    next_page = login_page.forms.first.submit

    return is_logged_in?
  end

  def export_heart_rate
    export_link = "https://api.azumio.com/v1/checkins?_format=csv&_fields=created,type,value,note&type=heartrate"
    csv_data = @agent.get(export_link).content
    CSV.parse(csv_data, headers: :first_row).by_row.map do |row|
      {
        date: Time.at(row['created'].to_i/1000).to_datetime,
        value: row['value'],
        note: row['note']
      }
    end
  end

  def is_logged_in?
    @agent.page.links.any?{|t| t.text == "LOGOUT"}
  end
end
