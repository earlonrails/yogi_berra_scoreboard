class ProcessPresentation
  def self.perform(presentation_id)
    presentation = Presentation.find(presentation_id)
    presentation.process!
  end
end