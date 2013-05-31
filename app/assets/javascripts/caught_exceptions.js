function dismissError(errorId) {
    $.post("/dismiss", { "error_id" : errorId }, function(results) {
       if (results.success) $("#" + errorId).remove();
    });
}
