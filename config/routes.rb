require_dependency "discourse_group_assign_by_custom_field_constraint"

DiscourseGroupAssignByCustomField::Engine.routes.draw do
  get "/" => "discourse_group_assign_by_custom_field#index", constraints: DiscourseGroupAssignByCustomFieldConstraint.new
  get "/actions" => "actions#index", constraints: DiscourseGroupAssignByCustomFieldConstraint.new
  get "/actions/:id" => "actions#show", constraints: DiscourseGroupAssignByCustomFieldConstraint.new
end
