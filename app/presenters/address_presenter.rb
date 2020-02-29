class AddressPresenter < BasePresenter
  def to_html
    lat = model.latitude.present? ? "Latitude: #{model.latitude}" : nil
    lng = model.longitude.present? ? "Longitude: #{model.longitude}" : nil

    html = [model.flat, model.street, "#{model.city}, #{model.postal_code}", lat, lng]
           .compact.delete_if(&:empty?).join('<br/>')
    h.sanitize(html)
  end

  def for_map
    if model.latitude.present? && model.longitude.present?
      [latitude, longitude].join(',')
    else
      [model.flat, model.street, model.city, model.postal_code].delete_if(&:empty?).join(',+')
    end
  end

  def to_s
    [model.flat, model.street, model.city, model.postal_code].delete_if(&:empty?).join(', ')
  end
end
