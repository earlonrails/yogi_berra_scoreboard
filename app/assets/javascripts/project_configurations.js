// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  var queryBox = $('.mongo-query-box'),
      queryReturn = $('#query-return');

  $('.query-adder').click(function(element) {
    var queryElement = $(this),
        queryPart = "\"" + queryElement.attr("data-query-part") + "\" : \"" + queryElement.children()[2].innerHTML.replace(/^\s+|\s+$/g,'') + "\"";

    if (queryBox.val() == "Enter mongo query ...") {
      queryBox.val("{ " + queryPart + " }");
    } else {
      queryBox.val(queryBox.val().slice(0, -1))
      queryBox.val(queryBox.val() + ", " + queryPart + " }");
    }
  });

  $('.query-clear').click(function() {
    queryBox.val("Enter mongo query ...");
    queryReturn.html("");
    queryReturn.hide();
  });

  $('.query-test').click(function() {
    var query = queryBox.val();
    $.ajax({
      url: "/raw_query",
      type: "POST",
      data: { query: query }
    })
    .done(function(data) {
      queryReturn.show();
      queryReturn.append(data);
    });
  });
});