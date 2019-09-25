class WorkshopPresenter < EventPresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ActionView::Helpers::DateHelper

  def venue
    model.host
  end

  def organisers
    @organisers ||= model.permissions.find_by(name: 'organiser').members rescue chapter_organisers
  end

  # Gets an HTML list of the organisers, with mobile numbers if the event's
  # not past and the user's logged in.
  def organisers_as_list(logged_in = false)
    list = organisers.shuffle.map do |o|
      organiser = ActionController::Base.helpers.link_to(o.full_name, o.twitter_url)
      organiser << " - #{o.mobile}" if logged_in && model.future? && o.mobile
      content_tag(:li, organiser)
    end.join.html_safe
    if list.blank?
      list = content_tag(:li, 'Nobody yet')
    end
    content_tag(:ul, list)
  end

  def attendees_csv(headers: true)
    attributes = %w{full_name role about_you first_time}
    @attendees_csv ||= CSV.generate(headers: true) do |csv|
      csv << attributes if headers
      attendee_array.each { |a| csv << a }
    end
  end

  def attendees_checklist
    "Students\n\n" + students_checklist + "\n\n\n\nCoaches\n\n" + coaches_checklist
  end

  def attendees_emails
    Member.joins(:workshop_invitations)
          .where('workshop_invitations.workshop_id = ? and attending =?', model.id, true)
          .pluck(:email).join(', ')
  end

  def time
    I18n.l(model.time, format: :time)
  end

  def path
    Rails.application.routes.url_helpers.workshop_path(model)
  end

  def admin_path
    Rails.application.routes.url_helpers.admin_workshop_path(model)
  end

  def distance_of_time
    past? ? "(#{distance_of_time_in_words_to_now(date_and_time)} ago)" :
            "(in #{distance_of_time_in_words_to_now(date_and_time)})"
  end

  private

  def students_checklist
    model.attending_students.order('note asc').each_with_index.map do |a, pos|
      "#{member_info(a.member, pos)}\t\t\t#{note(a)}"
    end.join("\n\n")
  end

  def coaches_checklist
    model.attending_coaches.each_with_index.map do |a, pos|
      member_info(a.member, pos).to_s
    end.join("\n\n")
  end

  def attendee_array
    attendees = WorkshopOrganiserInvitationPresenter.decorate_collection(organisers)
                                                    .sort_by(&:full_name)
    attendees += WorkshopInvitationPresenter.decorate_collection(non_organisers)
                                            .sort_by{ |i| [i.role, i.full_name]}
    attendees.map do |item|
      [item.full_name, item.role, item.note, item.about_you, item.newbie?]
    end
  end

  def non_organisers
    model.attendances.select { |invite| organisers.exclude?(invite.member) }
  end

  def member_info(member, pos)
    "#{MemberPresenter.new(member).newbie? ? "I__" : "___"} #{pos + 1}.\t #{member.full_name}"
  end

  def note(invitation)
    "#{invitation.note.present? ? invitation.note : "__________________________"} "
  end
end
