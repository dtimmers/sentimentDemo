var extTypes= ['csv', 'txt'];

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
};