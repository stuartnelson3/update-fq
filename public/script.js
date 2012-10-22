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
  var goal = "/back-in-stock";
  var params = {
    type: "GET",
    url: goal,
    data: "email="+ $("#email").val() + "&product="+$("#product").val()+"&size="+$("#size").val(),
    dataType: 'text',
		success: function() {},
    error: function(jqXHR, textStatus, errorThrown) {
      alert("Sent.");
    }
  };
  $.ajax(params);
});