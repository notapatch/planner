class BasePresenter < SimpleDelegator
  protected

  def h
    ActionController::Base.helpers
  end

  def html_escape(*args)
    ERB::Util.html_escape(*args)
  end

  private

  def model
    __getobj__
  end
end
