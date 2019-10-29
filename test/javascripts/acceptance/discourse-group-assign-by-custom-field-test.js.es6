import { acceptance } from "helpers/qunit-helpers";

acceptance("discourse-group-assign-by-custom-field", { loggedIn: true });

test("discourse-group-assign-by-custom-field works", async assert => {
  await visit("/admin/plugins/discourse-group-assign-by-custom-field");

  assert.ok(false, "it shows the discourse-group-assign-by-custom-field button");
});
