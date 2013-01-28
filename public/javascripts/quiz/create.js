(function($) {

	var Question = Backbone.Model.extend( {
		
		checkFields: function(){
			var q = this.get("question");
			var c1 = this.get("choice1");
			var c2 = this.get("choice2");
			var c3 = this.get("choice3");
			var c4 = this.get("choice4");
			if(q == undefined){
				return "No question provided!";
			} else if((c1 == undefined) || (c2 == undefined) || (c3 == undefined) || (c4 == undefined)){
				return "Please provide all choices!";
			} else {
				return false;
			}
		}
	});

	var Quiz = Backbone.Collection.extend( {
		model : Question
	});

	var QuestionView = Backbone.View.extend( {
		tagName : "div",
		className : "span4",
		template : $("#questionTemplate").html(),
		render : function() {
			_.templateSettings = {
				 interpolate : /\{\{(.+?)\}\}/g
			};
			var tmpl = _.template(this.template);
			this.$el.html(tmpl(this.model.toJSON()));
			return this;
		},

		deleteQuestion : function() {
			this.model.destroy();
			this.remove();
		},
		
		optionClicked: function(e){
			this.model.set("answer", e.target.value);
		},
		
		events: {
			"click .delete" : "deleteQuestion",
			"click input:radio" : "optionClicked"
				
		}
	});

	var QuizView = Backbone.View.extend( {
		el : $("#quiz"),

		initialize : function() {
			this.collection = new Quiz(quiz);
			this.render();
			this.collection.on("add", this.renderQuestion, this);
			this.collection.on("remove", this.removeQuestion, this);
		},

		render : function() {
			that = this;
			_.each(this.collection.models, function(item) {
				that.renderQuestion(item);
			}, this);
		},

		renderQuestion : function(item) {
			var questionView = new QuestionView( {
				model : item
			});
			this.$el.append(questionView.render().el);
		},

		addQuestion : function(e) {
			e.preventDefault();
			var formData = {};
			$("#addQuestion div").children("input").each(function(i, el) {
				if ($(el).val() !== "") {
					formData[el.id] = $(el).val();
				}
			});
			var question = new Question(formData);
			var err = question.checkFields();
			if(err) {
				alert(err);
			} else {
				quiz.push(formData);
				this.collection.add(question);
				$("#addQuestion div").children("input").val('');
			}
			
		},
		
		removeQuestion: function(removedQuestion){
			var removedQuestionData = removedQuestion.attributes;
		    _.each(removedQuestionData, function(val, key){
		        if(removedQuestionData[key] === removedQuestion.defaults[key]){
		            delete removedQuestionData[key];
		        }
		    });
			_.each(quiz, function(question){
				if(_.isEqual(question, removedQuestionData)){
					quiz.splice(_.indexOf(quiz, question), 1);
				}
			});
		},
		
		saveQuiz: function(){
			that = this;
			var json = {};
			var index = 0;
			_.each(this.collection.models, function(item) {
				console.log(item.toJSON());
			}, this);
			console.log(this.collection.models);
			console.log(JSON.stringify({quiz: this.collection.models}));
			$.ajax({
				type: "POST",
				url: "create",
				data: {quiz: JSON.stringify(this.collection.models) },
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
			"click #add" : "addQuestion",
			"click #save" : "saveQuiz"
				
		}
	});
	
	var QuizAnswerView = Backbone.View.extend( {
		el: $("quizAnswer"),
		
		initialize: function(){
			this.collection = new Quiz(quiz);
			this.render();
		},
		
		render: function(){
			renderQuestion(this.collection.models[1]);
		},
		
		renderQuestion: function(item){
			var answeringView = new AnsweringView({model: item});
			this.$el.append(answeringView.render().el);
		}
		
	});

	var quiz = [ ]

	var quizView = new QuizView();

})(jQuery);