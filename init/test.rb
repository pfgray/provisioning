# Run in screen/tmux to avoid losing progress if the connection drops
headers = ["Shard ID", "Root Account", "Root Account Domains", "Tool URL", "Tool ID"]

CSV.open("tool_report.csv", "a") do |csv|
  csv << headers
  
  Shard.with_each_shard(parallel: true) do
    tools_scope = ContextExternalTool.active.where(
      "settings like ?", "%vnd.instructure.User.uuid%"
    ).group(:domain, :url, :root_account_id, :tool_id).count.each do |k, v|
      csv << [
        Shard.current.id,
        k[2], # root account ID
        (Account.find(k[2]).account_domains.map { |d| d.host }.join ":"),
        k[0] || k[1], # tool URL,
        k[3] # tool ID
      ]
    end
  end
end;""