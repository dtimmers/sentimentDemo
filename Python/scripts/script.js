$(document).ready(function($) {
	$("input[name='figButton']").change(function() {
            var value = "img[id='" + $(this).val() + "']";
            $('.active_sentiment').removeClass('active_sentiment').addClass('nonactive_sentiment');
            $(value).removeClass('nonactive_sentiment').addClass('active_sentiment');
        });

	$('#term_form').change(function() {
		var value = $('#termSelect').val();
		var name = $('#termSelect')
		var input = $("<input>").attr("type", "hidden").attr("name", "searchTerm").val(value);
		$(this).append($(input));
		$(this).submit();
	});
});