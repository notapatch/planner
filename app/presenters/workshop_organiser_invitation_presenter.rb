class WorkshopOrganiserInvitationPresenter < BasePresenter
  def self.decorate_collection(collection)
    collection.map do |e|
      WorkshopOrganiserInvitationPresenter.new(e)
    end
  end

  def role
    'ORGANISER'
  end

  def note
    ''
  end

  delegate :newbie?, to: :member

  private

  def member
    @member ||= MemberPresenter.new(model)
  end
end
