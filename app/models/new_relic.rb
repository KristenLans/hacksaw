class NewRelic

  APP = 446884
  ACC = 5035

  def self.link
    "https://rpm.newrelic.com/accounts/#{ACC}/applications/#{APP}"
  end

  def self.apdex_day
    JSON.parse(curl("data.json?metrics[]=EndUser/Apdex&field=score&begin=#{yesterday}&end=#{today}"))
  end

  def self.apdex_day_avg
    scores = apdex_day
    scores.map { |res| res["score"] }.inject{ |sum, score| sum + score }.to_f / scores.size
  end

  # I can't seem to get LESS than a day's worth of data, go figure.  :\
  def self.apdex
    apdex_day.last["score"]
  end

  # TODO - this doesn't work because the .json returns xml.  :|
  def self.thresholds
    JSON.parse(curl("threshold_values.json"))
  end

  private

    def self.yesterday
      time_fmt(Time.now - 1.day)
    end

    def self.today
      time_fmt(Time.now)
    end

    def self.time_fmt(time)
      time.strftime('%Y-%m-%dT00:00:00Z')
    end

    def self.curl(cmd, options = {})
      url = "https://api.newrelic.com/api/v1/"
      url += "accounts/#{ACC}/" unless options[:no_account]
      url += "applications/#{APP}/" unless options[:no_app]
      url += cmd
      response = Curl::Easy.perform(url) do |curl|
        curl.headers["x-api-key"] = Hacksaw::Application.config.newrelic_key
      end
      response.body_str
    end

end
