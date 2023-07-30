class KoyoReplHandlers
  def self.koyo_handle_all_replication(row)
    msg = [
      '#' * 80,
      'KoyoReplHandlers.koyo_handle_all_replication called',
      row.to_yaml,
      '#' * 80
    ]
    puts msg
  end
end
