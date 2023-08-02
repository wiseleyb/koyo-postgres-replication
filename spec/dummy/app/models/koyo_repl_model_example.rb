class KoyoReplHandler
  # example row:
  # User.handle_replcation called
  # TODO: Add link to class returned
  def self.koyo_handle_all_replication(row)
    # puts row.to_yaml
  end

  # log_leve: :debug, :info, :warn, :error, :fatal
  # Example of message
  # source=KoyoReplication logid=d7f1f0bb2a
  #   message=Init: Finding models that support koyo_repl_handler
  def self.koyo_log_event(message, log_level)
    # puts message
  end
end
