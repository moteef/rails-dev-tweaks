# Here's an idea, let's not reload the entire dev environment for each asset request.  Let's only do that on regular
# content requests.
class RailsDevTweaks::GranularAutoload::Middleware < ActionDispatch::Reloader

  def call(env)
    request = ActionDispatch::Request.new(env.dup)

    # reload, or no?
    if Rails.application.config.dev_tweaks.granular_autoload_config.should_reload?(request) && reload_dependencies?
      return super
    else
      Rails.logger.info 'RailsDevTweaks: Skipping ActionDispatch::Reloader hooks for this request.' if Rails.application.config.dev_tweaks.log_autoload_notice
      return @app.call(env)
    end
  end

  private

  def reload_dependencies?
    application = Rails.application

    # Rails 3.2 defines reload_dependencies? and it only reloads if reload_dependencies? returns true.
      (!application.class.method_defined?(:reload_dependencies?) ||
        application.send(:reload_dependencies?))
  end
end
