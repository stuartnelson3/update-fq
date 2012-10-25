$(document).on("click", ".js-submit", function(){
  var params_tops = {
			type: 'POST',
			url: 'http://fitquiz.quincyapparel.com/ufq.php',
			dataType:"text",
			data: {
				shop: "quincy.myshopify.com",
				cid: $('input[name=cid]').val(),
				fq_bust: $(".bust_value").val(),
				fq_length: $(".length_value").val()
			},
			success: function() {},
      error: function(jqXHR, textStatus, errorThrown) {
        alert("Tops updated.");
      }
    };
	var params_bottoms = {
		type: 'POST',
		url: 'http://fitquiz.quincyapparel.com/ufq.php',
		data: {
			shop: "quincy.myshopify.com",
			cid: $('input[name=cid]').val(),
			fq_waist: $(".waist_value").val()
		},
		success: function() {},
    error: function(jqXHR, textStatus, errorThrown) {
      alert("Bottoms updated.");
    }	
		};
  $.ajax(params_bottoms);
  $.ajax(params_tops);
});
$(document).on("click", ".js-test", function() {
  var url = "/back-in-stock";
  var params = {
    type: "GET",
    url: url,
    data: "email="+ $("#email").val() + "&product="+$("#product").val()+"&size="+$("#size").val(),
    dataType: 'text',
		success: function(data, textStatus, jqXHR) {
		  alert("Sent." + " data: " + data + ", textstats: " + textStatus + ", jqxhr: " + jqXHR);
		},
    error: function(jqXHR, textStatus, errorThrown) {
      alert("Sent." + " jqxhr: " + jqXHR + ", textstats: " + textStatus + ", errorThrown: " + errorThrown);
    }
  };
  $.ajax(params);
});
$(document).on("click", ".js-customer-followup", function() {
  var url = "/customer-followup";
  var params = {
    type: "POST",
    url: url,
    data: "start=" + $("#customer .customer-start").val() + "&end=" + $("#customer .customer-end").val(),
    dataType: 'json',
		success: function(data, textStatus, jqXHR) {
		  alert(data);
		},
    error: function(jqXHR, textStatus, errorThrown) {
      alert("Error.");
    }
  };
  $.ajax(params);
});
$(document).on("click", ".js-review-followup", function() {
  var url = "/review-followup";
  var params = {
    type: "POST",
    url: url,
    data: "start=" + $("#review .customer-start").val() + "&end=" + $("#review .customer-end").val(),
    dataType: 'json',
		success: function(data, textStatus, jqXHR) {
		  alert(data);
		},
    error: function(jqXHR, textStatus, errorThrown) {
      alert("Error.");
    }
  };
  $.ajax(params);
});