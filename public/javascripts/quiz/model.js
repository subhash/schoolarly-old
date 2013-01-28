(function($) {
	var Question = Backbone.Model.extend( {
		defaults : {
			coverImage : "img/placeholder.png",
			question : "What's your favourite colour?",
			choice1 : "Yellow",
			choice2 : "Orange",
			choice3 : "Red",
			choice4 : "Pink"
		}
	});

	var Quiz = Backbone.Collection.extend( {
		model : Question
	});
})(jQuery);