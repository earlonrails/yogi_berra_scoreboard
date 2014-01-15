// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$(function() {
  var queryBox = $('.mongo-query-box');

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
  });

  $('.query-test').click(function() {
    var query = queryBox.val();
    $.ajax({
      url: "/raw_query.json",
      type: "POST",
      data: { query: query },
      dataType: 'json'
    }).done(function(data) {
      var queryReturn = ace.edit("query-return");
      queryReturn.setTheme("ace/theme/twilight");
      queryReturn.session.setMode("ace/mode/json");
      queryReturn.getSession().setValue(JSON.stringify(data));
    }).fail(function(data) {
      alert( "error" );
    })
  });
});