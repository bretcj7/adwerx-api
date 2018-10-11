require 'parallel'
require 'rest-client'
require 'json'

class Star < ApplicationRecord
  include ActiveModel::Serializers::JSON

  BASE_URL = 'https://api.github.com/search/repositories?q='
  STARS = '1..2000'
  DATE = (Time.now - 1.day).strftime('%Y-%m-%d')
  CODE1 = 'ruby'
  CODE2 = 'javascript'
  LIC1 = 'mit'
  LIC2 = 'gpl'
  LIC3 = 'lgpl'
  LIC4 = 'apache-2.0'

  URL1 = URI::encode("#{BASE_URL}language:#{CODE1}&forks:0&pushed:>=#{DATE}&stars:#{STARS}&license:#{LIC1}")
  URL2 = URI::encode("#{BASE_URL}language:#{CODE1}&forks:0&pushed:>=#{DATE}&stars:#{STARS}&license:#{LIC2}")
  URL3 = URI::encode("#{BASE_URL}language:#{CODE1}&forks:0&pushed:>=#{DATE}&stars:#{STARS}&license:#{LIC3}")
  URL4 = URI::encode("#{BASE_URL}language:#{CODE1}&forks:0&pushed:>=#{DATE}&stars:#{STARS}&license:#{LIC4}")
  URL5 = URI::encode("#{BASE_URL}language:#{CODE2}&forks:0&pushed:>=#{DATE}&stars:#{STARS}&license:#{LIC1}")
  URL6 = URI::encode("#{BASE_URL}language:#{CODE2}&forks:0&pushed:>=#{DATE}&stars:#{STARS}&license:#{LIC2}")
  URL7 = URI::encode("#{BASE_URL}language:#{CODE2}&forks:0&pushed:>=#{DATE}&stars:#{STARS}&license:#{LIC3}")
  URL8 = URI::encode("#{BASE_URL}language:#{CODE2}&forks:0&pushed:>=#{DATE}&stars:#{STARS}&license:#{LIC4}")

  def get_stars()
    sarray = [URL1, URL2, URL3, URL4, URL5, URL6, URL7, URL8]
    results = Parallel.each(sarray) do |req|
      response = RestClient.get(req, {accept: :json})
      if response.code == 200
        json =  JSON.parse(response)
        puts 'before len'
        puts json['items'].length
        json_trimmed = json['items'].map do |v|
          {
            name: v['name'],
            url: v['html_url'],
            owner: v.dig('owner', 'login'),
            stars: v['stargazers_count']
          }
        end
        Star.import [:name, :owner, :url, :stars], json_trimmed, validate: false
      end
    end
  end
end
