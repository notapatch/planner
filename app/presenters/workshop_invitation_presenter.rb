class WorkshopInvitationPresenter < BasePresenter
  def self.decorate_collection(collection)
    collection.map do |e|
      WorkshopInvitationPresenter.new(e)
    end
  end

  delegate :full_name, to: :member

  def role
    model.role.upcase
  end

  delegate :about_you, to: :member
  delegate :newbie?, to: :member

  private

  def member
    @member ||= MemberPresenter.new(model.member)
  end
end
