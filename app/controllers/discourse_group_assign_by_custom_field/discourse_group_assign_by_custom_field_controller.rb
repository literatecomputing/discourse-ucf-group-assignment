module DiscourseGroupAssignByCustomField
  class DiscourseGroupAssignByCustomFieldController < ::ApplicationController
    requires_plugin DiscourseGroupAssignByCustomField

    before_action :ensure_logged_in

    def index
    end
  end
end
