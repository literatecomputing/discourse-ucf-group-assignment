import RestAdapter from "discourse/adapters/rest";

export default RestAdapter.extend({
  basePath() {
    return "/discourse-group-assign-by-custom-field/";
  }
});
