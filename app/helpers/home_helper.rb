module HomeHelper
  def count_down_start_time
    def dd(d,p=2)
      d < 10**(p-1) ? "#{"0"*(p-d.to_s.length)}#{d}" : d
    end

    d = Time.utc('2014','7','19')
    n = Time.now
    offset = d - n
    offset = 0 if offset < 0

    days = (offset / (3600 * 24)).to_i; offset -= days * (3600 * 24)
    hours = (offset / 3600).to_i; offset -= hours * 3600
    minutes = (offset / 60).to_i
    seconds = (offset - minutes * 60).to_i

    "#{dd(days,2)}:#{dd(hours)}:#{dd(minutes)}:#{dd(seconds)}"
  end
end
