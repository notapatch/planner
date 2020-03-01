class CoursePresenter < EventPresenter
  def description
    h.sanitize model.description
  end

  def venue
    model.sponsor
  end

  def sponsors
    [sponsor].compact
  end

  def admin_path
    '#'
  end
end
