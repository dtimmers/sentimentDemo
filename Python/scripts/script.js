$( document ).ready(function() {

	$("#figures").change(function(){
		console.log($('#figures'));
		console.log(this.files);
		/*var fn = $("#figure").val().replace(/C:\\fakepath\\/i, '');
		console.log(fn)*/
	});
});

/*var extTypes= ['csv', 'txt'];

function validateForm(formElement) {
	var path = formElement.csvfile.value;
	if (path.length > 3) {
		var ext = path.substr(path.length - 3);
		if ( extTypes.indexOf(ext) >= 0 ) {
			return true;
		}
		else {
			alert("The file must either be a txt or csv file");
			return false;
		}
	}
	else {
		alert("The file must either be a txt or csv file");
		return false;
	}
	
};

function swapPlot() {
	var image = document.getElementById('significancePlot');
	var dropd = document.getElementById('plotSelect');
	image.src = dropd.value;
};*/

/*	$('#name').attr("disabled", true);
	$('#date').attr("disabled", true);
	$('#search_term').attr("disabled", true);*/