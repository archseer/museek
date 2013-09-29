require_relative 'museek'

museek = Museek.new(password: ARGV.shift)
museek.start

trap('INT') do
  exit 0
end

loop do
end
