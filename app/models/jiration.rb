class Jiration
  require 'net/http'
  require 'json'
  
  attr_accessor :data
  
  def initialize
    self.data = JSON.parse(Net::HTTP.get_response(URI.parse('http://issues.eol.org/api')).body)
  end
  
  def average_userpain
    self.data['avg_userpain']    
  end
  
  def eol_issue_count
    self.data['eol_issue_count']
  end
  
  def content_issue_count
    self.data['content_issue_count']
  end
    
end
