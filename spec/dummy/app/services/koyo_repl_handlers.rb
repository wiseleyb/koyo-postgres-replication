class KoyoReplHandlers
  def self.koyo_handle_all_replication(row)
    puts 'KoyoReplHandlers.koyo_handle_all_replication called'
  end

  def self.koyo_log_event(msg, lvl)
    puts 'KoyoReplHandlers.koyo_log_event called'
  end
end
