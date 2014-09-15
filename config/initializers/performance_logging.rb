# Subscribes to performance instruments throughout the app & logs their results

ActiveSupport::Notifications.subscribe(
  "SolrRequest.get_data_for_articles"
) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.debug(
    "#{event.name} for #{event.payload.size} articles took #{event.duration}ms."
  )
end

ActiveSupport::Notifications.subscribe(
  "SolrRequest.get_data_for_viz"
) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.debug(
    "#{event.name} for #{event.payload.size} articles took #{event.duration}ms."
  )
end

ActiveSupport::Notifications.subscribe(
  "SolrRequest.validate_dois"
) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.debug(
    "#{event.name} for #{event.payload.size} articles took #{event.duration}ms."
  )
end

