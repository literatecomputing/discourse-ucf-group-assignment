export default function() {
  this.route("discourse-group-assign-by-custom-field", function() {
    this.route("actions", function() {
      this.route("show", { path: "/:id" });
    });
  });
};
