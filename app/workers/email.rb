class Email
  def self.perform(project_id)
    project = ProjectConfiguration.find(project_id)
    project.thresholds.each do |threshold|

    end
  end
end