function dismissError(errorId) { 
    $.post("/dismiss", { error: errorId }, function(results) { 
       if (results.success) $("#" + errorId).remove(); 
    });
}
