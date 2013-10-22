$(document).ready(function($) {
	/*  Switch the sentiment images using the radio buttons */
	$("input[name='figButton']").change(function() {
            var value = "img[id='" + $(this).val() + "']";
            console.log(value)
            $('.active_sentiment').removeClass('active_sentiment').addClass('nonactive_sentiment');
            $(value).removeClass('nonactive_sentiment').addClass('active_sentiment');
        });

	/* To send correct post while there is no submit button */
	$('#term_form').change(function() {
		var value = $('#termSelect').val();
		var input = $("<input>").attr("type", "hidden").attr("name", "searchTerm").val(value);
		$(this).append($(input));
		$(this).submit();
	});

	/* Check whether the list of files is not empty */
	$('#figures').bind('change', function() {
		if( $(this)[0].files.length > 0 ){
			$('#upFigures').removeAttr('disabled');
		};
	});
});