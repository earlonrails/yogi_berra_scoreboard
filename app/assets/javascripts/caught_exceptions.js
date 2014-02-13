function dismissError(errorId, firstLine) {
  $.ajax({
    type: "POST",
    url: "/dismiss",
    data: { "error_id" : errorId, "line_one" : firstLine },
    dataType: "json"
  }).done(function(data){
    $("#" + errorId).fadeTo(500, 0).slideUp(500, function(){
      $(this).remove();
    });
  });
}
