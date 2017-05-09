# frozen_string_literal: true

require_relative 'py_deputatos'

class MemberPage < PyDeputatos::HTML
  field :constituency do
    datos.xpath('.//td[contains(text(),"Departamento")]/following-sibling::td').text.coerce_utf8.tidy
  end

  private

  def datos
    noko.css('table.tex').first
  end
end
