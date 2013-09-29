require 'bindata'

class MuseekString < BinData::Primitive
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
  museek_string :challenge
end

class Ping < BinData::Record
  endian :little
  uint32 :code, :value => 000
  uint32 :id
end

class ServerState < BinData::Record
  endian :little
  bool :connected
  museek_string :username
end

module Incoming
  class Status < BinData::Record
    endian :little
    uint32 :status
  end

  class Login < BinData::Record
    endian :little
    bool :ok
    museek_string :message
    museek_string :challenge
  end
end

module Outgoing

  class Login < BinData::Record
    endian :little
    uint32 :code, :value => 002
    museek_string :algorithm
    museek_string :chresponse
    uint32 :mask
  end
end