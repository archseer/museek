require 'bindata'

# - primitive types
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

# - complex types

class UserData < BinData::Record
  endian :little
  uint32 :status
  uint32 :avgspeed
  uint32 :downloadnum
  uint32 :files
  uint32 :dirs
  bool :slotsfree
end

class Transfer < BinData::Record
  endian :little
  bool :is_upload
  m_string :user
  m_string :path
  uint32 :place # in queue
  uint32 :state
  m_string :error
  int64 :position
  int64 :filesize
  uint32 :rate
end

class MFile < BinData::Record
  endian :little
  int64    :filesize
  m_string :ext
  uint32   :numattrs
  array :attrs, :initial_length => :numattrs do
    uint32
  end
end

class Folder < BinData::Record
  endian :little
  uint32 :numfiles
  array :files, :initial_length => :numfiles do
    m_string :file
    m_file :info
  end
end

class SharesDB < BinData::Record
  endian :little
  uint32 :numfolders
  array :folders, :initial_length => :numfolders do
    m_string :folder
    folder :files
  end
end

# - 0xx range -- Basic

class Ping < BinData::Record
  endian :little
  uint32 :id
end

class Challenge < BinData::Record
  endian :little
  uint32 :version
  m_string :challenge
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

class StatusMessage < BinData::Record
  endian :little
  bool :messagetype
  m_string :message 
end

# - 1xx range -- Configuration

# - 2xx range -- Peer data
class PeerExists < BinData::Record
  endian :little
  m_string :username
  bool :exists
end

class PeerStatus < BinData::Record
  endian :little
  m_string :username
  uint32 :status # TODO: parse 0 - offline, 1 - away, 2 - online
end

class PeerStatistics < BinData::Record
  endian :little
  m_string :username
  uint32 :avgspeed
  uint32 :numdownloads
  uint32 :numfiles
  uint32 :numdirs
end

class UserInfo < BinData::Record
  endian :little
  m_string :username
  m_string :info
  m_string :picture
  uint32 :uploads
  uint32 :queuelen
  bool :slotfree
end

class PeerAddress < BinData::Record
  endian :little
  m_string :username
  m_string :ip
  uint32   :port
end

# - 3xx range - Rooms

# - 4xx range - Search

class Search < BinData::Record
  endian :little
  m_string :query
  uint32 :ticket
end

class SearchReply < BinData::Record
  endian :little
  uint32 :ticket
  m_string :username
  bool :slotfree
  uint32 :avgspeed
  uint32 :queuelen
  folder :results
end

# - 5xx range - Transfers

# - 6xx range - Recommendations, similar users

# - 7xx range - Connection, rescan shares

# Unknown response handler

class Unknown < BinData::Record
  mandatory_parameter :len
  endian :little
  string :payload, :read_length => :len
end

# Client sent

  class Client_Login < BinData::Record
    endian :little
    uint32 :code, :value => 0x002
    m_string :algorithm
    m_string :chresponse
    uint32 :mask
  end

class Client_PeerExists < BinData::Record
  endian :little
  uint32 :code, :value => 0x201
  m_string :username
end

class Client_PeerStatus < BinData::Record
  endian :little
  uint32 :code, :value => 0x202
  m_string :username
end

class Client_Search < BinData::Record
  endian :little
  uint32 :code, :value => 0x401
  uint32 :type
  m_string :query
end

# --- Encapsulates the main message format and parsing, 
# automatically detecting the message type.

class Master < BinData::Record
  endian :little
  uint32 :len
  uint32 :code
  choice :params, :selection => :code do
    ping           0x000
    challenge      0x001
    login          0x002
    server_state   0x003
    status         0x005
    status_message 0x010

    peer_exists     0x201
    peer_status     0x202
    peer_statistics 0x203
    user_info       0x204
    # 0x205
    peer_address    0x206

    search       0x401
    search_reply 0x402
    
    unknown :default, :len => lambda { len - 4 }
  end
end