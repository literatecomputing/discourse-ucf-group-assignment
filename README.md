# deprecated: See https://github.com/literatecomputing/discourse-ucf-group-assignment

Assign a user to a group according to a custom user field.

The user field and the value-to-group mapping are configurable in site settings.

- `user_custom_field_map_name` is used to indicate which custom field to watch
- `user_custom_field_map` maps the custom field value to the group (group must exist). For example, adding these two values:
   - one:group_one
	 - two:group_two
implies that a user updating the custom field to "one" will add the userto group_one and also remove the user from group two (if the user was in that group).
- 'user_custom_group_add_only` will not delete the user from other groups, so if a user saves value to "one" and then saves it to "two" the user will be in both groups.
## Installation

Follow [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157)
how-to from the official Discourse Meta, using `git clone https://github.com/pfaffman/discourse-group-assign-by-custom-field.git`
as the plugin command.

## Usage
