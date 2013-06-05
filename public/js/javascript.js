$(document).ready(function() {
  $("#to").live("change", function() { preview(); });
  $("#message").live("keyup", function() { preview(); });
  $("#cancel").click(function() { cancel(); });
  
  $(".loading").click(function() {
    loading();
  });
  
  //$("#loading").click(function() { $("#loading").hide(); });
});

function preview() {
  var to = $("#to").val();
  var message = $("#message").val();
  $("#preview").html(to + " " + message);
}

function loading() {
  $("#loading").show();
  setInterval( "loadingMessage()", 100 );
}

function loadingMessage() {
  $("#loading-message").append(".");
}

function cancel() {
  if(window.confirm('本当にshikakunをやめますか?')){
    loading();
		location.href = "/cancel";
	}
}

function test(a) {
	if(a == null){ a = "alert!" }
	window.alert(a);
}