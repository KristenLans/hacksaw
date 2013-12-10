class Time
  def javascript_date
    # new Date(Year, Month[zero index], Day, Hour, Minute, Second)
    return strftime("new Date(%Y, #{strftime('%-m').to_i - 1}, %-d, %H, %M, %S)")
  end
end
