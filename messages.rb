require 'bindata'

class MString < BinData::Primitive
  endian :little
  uint32 :len,  :value => lambda { data.length }
  string :data, :read_length => :len

  def get;   self.data; end
  def set(v) self.data = v; end
end

class Bool < BinData::Primitive
  uint8 :data

  def get
    self.data != 0
  end

  def set(v)
    self.data = (v ? 1 : 0)
  end
end

class Challenge < BinData::Record
  endian :little
  uint32 :version
  m_string :challenge
end

class Ping < BinData::Record
  endian :little
  uint32 :id
end

class Login < BinData::Record
  endian :little
  bool :ok
  m_string :message
  m_string :challenge
end

class ServerState < BinData::Record
  endian :little
  bool :connected
  m_string :username
end

class Status < BinData::Record
  endian :little
  uint32 :status
end

# Client sent

  class Client_Login < BinData::Record
    endian :little
    uint32 :code, :value => 002
    m_string :algorithm
    m_string :chresponse
    uint32 :mask
  end


# --- Encapsulates the main message format and parsing, 
# automatically detecting the message type.

class Master < BinData::Record
  endian :little
  uint32 :len
  uint32 :code
  choice :params, :selection => :code do
    ping         0x000
    challenge    0x001
    login        0x002
    server_state 0x003
    status       0x005
    rest :default
  end
end