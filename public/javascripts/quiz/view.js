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

	var QuestionAnswerView = Backbone.View.extend( {
		tagName : "div",
		className : "questionContainer",
		template : $("#questionAnswerTemplate").html(),

		render : function() {
			_.templateSettings = {
		    	interpolate: /\<\@\=(.+?)\@\>/gim,
		    	evaluate: /\<\@(.+?)\@\>/gim,
		    	escape: /\<\@\-(.+?)\@\>/gim
			};
			var tmpl = _.template(this.template);
			var json = this.model.toJSON();
			json.id = this.id;
			this.$el.html(tmpl(json));
			return this;
		}
	});

	var QuizAnswerView = Backbone.View.extend( {
		el : $("#quizAnswer"),
		controls : $("#questionAnswerControls").html(),

		initialize : function() {
			this.collection = new Quiz(quiz);
			this.index = 0;
			this.render();
			this.answers = {};
		},

		render : function() {
			this.renderQuestion(this.collection.models[this.index]);
		},

		renderQuestion : function(item) {
			var questionAnswerView = new QuestionAnswerView( {
				model : item,
				id : this.index
			});
			this.$el.html(questionAnswerView.render().el);
			var tmpl = _.template(this.controls);
			var param = {
				"next" : (this.index < this.collection.models.length - 1),
				"back" : (this.index > 0)
			};
			this.$el.append(tmpl(param));
		},

		backQuestion : function() {
			if (this.index > 0)
				this.index = this.index - 1;
			this.render();
		},

		nextQuestion : function() {
			var selector = "input:radio[name=answer"+this.index+"]:checked";
			this.answers[this.index] = $(selector).val();
			if (this.index < this.collection.models.length - 1)
				this.index = this.index + 1;
			this.render();
		},

		save : function() {
			this.nextQuestion();
			console.log(this.answers);
			$.ajax({
				type: "POST",
				url: "add_new",
				data: {quiz_response: JSON.stringify(this.answers), quiz_id: $.getUrlVar("quiz_id"), foo: "fee" },
				dataType: "json",
				success: function(data, status){
					console.log(data);
					window.location.href = data.location;
				},
				error: function(data, status){
					console.log("error - "+status);
					console.log(data);
				}
			});			
		},

		events : {
			"click .next" : "nextQuestion",
			"click .back" : "backQuestion",
			"click .save" : "save"

		}

	});

	var quiz2 = [ {
		question : "What's your favourite colour?",
		choice1 : "Yellow",
		choice2 : "Orange",
		choice3 : "Red",
		choice4 : "Pink"
	}, {
		question : "How are you?",
		choice1 : "Happy",
		choice2 : "Sad",
		choice3 : "Dull",
		choice4 : "Bored"

	}, {
		question : "What's today?",
		choice1 : "Monday",
		choice2 : "Wednesday",
		choice3 : "Sunday",
		choice4 : "Friday"

	} ];

	var quizAnswerView = new QuizAnswerView();
	
    $.extend({
      getUrlVars: function(){
        var vars = [], hash;
        var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
        for(var i = 0; i < hashes.length; i++)
        {
          hash = hashes[i].split('=');
          vars.push(hash[0]);
          vars[hash[0]] = hash[1];
        }
        return vars;
      },
      getUrlVar: function(name){
        return $.getUrlVars()[name];
      }
    });	

})(jQuery);