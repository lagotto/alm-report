# Subscribes to performance instruments throughout the app & logs their results

[
  "SolrRequest.get_data_for_articles", "SolrRequest.validate_dois"
].each do |name|
  ActiveSupport::Notifications.subscribe(name) do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Rails.logger.debug(
      "#{event.name}: #{event.payload.size} articles took #{event.duration}ms."
    )
  end
end
