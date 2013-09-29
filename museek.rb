require 'socket'
require 'digest'
require_relative 'messages'

class Error < StandardError; end
class ConnectionError < Error; end
class ServerError < Error;  end

class InvalidMessageError < ConnectionError; end

class BasicSocket
  def ready?
    not IO.select([self], nil, nil, 0) == nil
  end
end

Thread.abort_on_exception = true

class Museek

  attr_reader :socket

  def initialize(params = {})
    @host = params[:host] || 'localhost'
    @port = params[:port] || 2240
    @password = params[:password]
  end

  def start
    @socket = TCPSocket.new(@host, @port)

    Thread.new do
      while true
        while @socket.ready?
          msg = fetch
          process(msg)
        end
        sleep 1
      end
    end
  end

  def fetch
    Master.read(@socket)
  end
  private :fetch

  def process(message)
    p message

    params = message[:params]

    case message[:code]
    when 0x001
      sha256 = Digest::SHA256.new
      sha256.update params[:challenge]
      sha256.update @password

      resp = Client_Login.new
      resp.algorithm = "SHA256"
      resp.chresponse = sha256.hexdigest
      resp.mask = 0x00

      send(resp)
    when 0x002, 0x003
    when 0x005
      resp = Client_Search.new
      resp.type = 0
      resp.query = ".ogg"
      send(resp)
    when 0x401, 0x402
    else
      puts "Unknown code! 0x#{'%03x' % message[:code]} with params #{message[:params].inspect}"
    end
  end

  def send(message)
    msg = message.to_binary_s
    response = [msg.length].pack("I<") + msg
    @socket.send response, 0
  end

end
