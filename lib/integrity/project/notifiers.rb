module Integrity
  class Project
    module Helpers
      module Notifiers
        def notifies?(notifier)
          return false unless notifier = notifiers.first(:name => notifier)

          notifier.enabled?
        end

        def enabled_notifiers
          notifiers.all(:enabled => true)
        end

        def config_for(notifier)
          notifier = notifiers.first(:name => notifier)
          notifier ? notifier.config : {}
        end

        def update_notifiers(to_enable, config)
          config.each_pair { |name, config|
            notifier = notifiers.first(:name => name)
            notifier ||= notifiers.new(:name => name)

            notifier.enabled = to_enable.include?(name)
            notifier.config  = config
            notifier.save
          }
        end
      end
    end
  end
end
