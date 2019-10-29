module DiscourseGroupAssignByCustomField
  class Engine < ::Rails::Engine
    engine_name "DiscourseGroupAssignByCustomField".freeze
    isolate_namespace DiscourseGroupAssignByCustomField

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::DiscourseGroupAssignByCustomField::Engine, at: "/discourse-group-assign-by-custom-field"
      end
    end
  end
end
