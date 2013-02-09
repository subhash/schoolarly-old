(function($) {
	console.log(page);
	console.log(quiz);

	var Question = Backbone.Model.extend({

		checkFields : function() {
			var q = this.get("question");
			var c1 = this.get("choice1");
			var c2 = this.get("choice2");
			var c3 = this.get("choice3");
			var c4 = this.get("choice4");
			if (q == undefined) {
				return "No question provided!";
			} else if ((c1 == undefined) || (c2 == undefined) || (c3 == undefined) || (c4 == undefined)) {
				return "Please provide all choices!";
			} else {
				return false;
			}
		}
	});

	var Quiz = Backbone.Collection.extend({
		model : Question,

		checkQuiz : function() {
			if (this.length < 1) {
				return "Please add questions"
			}
			var no_answer = _.find(this.models, function(item) {
				return (item.get("answer") == undefined);
			});
			if (no_answer)
				return "Please provide answers";
			if ($("#title").val() == "") {
				return "Please provide title";
			}
		}
	});

	var QuestionView = Backbone.View.extend({
		tagName : "div",
		className : "span4",
		template : $("#questionTemplate").html(),
		render : function() {
			_.templateSettings = {
				interpolate : /\<\@\=(.+?)\@\>/gim,
				evaluate : /\<\@(.+?)\@\>/gim,
				escape : /\<\@\-(.+?)\@\>/gim
			};
			var json = this.model.toJSON();
			json["chosen_answer"] = this.options["chosen_answer"];
			var tmpl = _.template(this.template);
			this.$el.html(tmpl(json));
			return this;
		},

		deleteQuestion : function() {
			this.model.destroy();
			this.remove();
		},

		optionClicked : function(e) {
			this.model.set("answer", e.target.value);
		},

		events : {
			"click .delete" : "deleteQuestion",
			"click input:radio" : "optionClicked"

		}
	});

	var QuizView = Backbone.View.extend({
		el : $("#quiz"),

		initialize : function() {
			this.index = 0;
			this.collection = new Quiz(quizData);
			this.render();
			this.collection.on("add", this.renderQuestion, this);
			this.collection.on("remove", this.removeQuestion, this);
		},

		render : function() {
			that = this;
			_.each(this.collection.models, function(item) {
				that.renderQuestion(item);
				this.index = this.index + 1;
			}, this);
		},

		renderQuestion : function(item) {
			var questionView = new QuestionView({
				model : item,
				chosen_answer : answerData[this.index]
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
			if (err) {
				alert(err);
			} else {
				quiz.push(formData);
				this.collection.add(question);
				$("#addQuestion div").children("input").val('');
			}

		},

		removeQuestion : function(removedQuestion) {
			var removedQuestionData = removedQuestion.attributes;
			_.each(removedQuestionData, function(val, key) {
				if (removedQuestionData[key] === removedQuestion.defaults[key]) {
					delete removedQuestionData[key];
				}
			});
			_.each(quiz, function(question) {
				if (_.isEqual(question, removedQuestionData)) {
					quiz.splice(_.indexOf(quiz, question), 1);
				}
			});
		},

		saveQuiz : function(e) {
			e.preventDefault();
			var err = this.collection.checkQuiz();
			if (err) {
				alert(err);
			} else {
				var json = {};
				var index = 0;
				$.ajax({
					type : "POST",
					url : "add_new",
					data : {
						quiz : JSON.stringify(this.collection.models),
						title : $("#title").val(),
						instruction : $("#instruction").val()
					},
					dataType : "json",
					success : function(data, status) {
						console.log('success');
						console.log(data);
						window.location.href = data.location;
					},
					error : function(data, status) {
						console.log("error - " + status);
						console.log(data);
					}
				});
			}
		},

		events : {
			"click #add" : "addQuestion",
			"click #save" : "saveQuiz"

		}
	});

	var QuizAnswerView = Backbone.View.extend({
		el : $("quizAnswer"),

		initialize : function() {
			this.collection = new Quiz(quiz);
			this.render();
		},

		render : function() {
			renderQuestion(this.collection.models[1]);
		},

		renderQuestion : function(item) {
			var answeringView = new AnsweringView({
				model : item
			});
			this.$el.append(answeringView.render().el);
		}
	});

	var QuestionAnswerView = Backbone.View.extend({
		tagName : "div",
		className : "questionContainer",
		template : $("#questionAnswerTemplate").html(),

		render : function() {
			_.templateSettings = {
				interpolate : /\<\@\=(.+?)\@\>/gim,
				evaluate : /\<\@(.+?)\@\>/gim,
				escape : /\<\@\-(.+?)\@\>/gim
			};
			var tmpl = _.template(this.template);
			var json = this.model.toJSON();
			json.id = this.id;
			this.$el.html(tmpl(json));
			return this;
		}
	});

	var QuizAnswerView = Backbone.View.extend({
		el : $("#quizAnswer"),
		controls : $("#questionAnswerControls").html(),

		initialize : function() {
			this.collection = new Quiz(quizData);
			this.index = 0;
			this.render();
			this.answers = {};
		},

		render : function() {
			this.renderQuestion(this.collection.models[this.index]);
		},

		renderQuestion : function(item) {
			var questionAnswerView = new QuestionAnswerView({
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
			var selector = "input:radio[name=answer" + this.index + "]:checked";
			this.answers[this.index] = $(selector).val();
			if (this.index < this.collection.models.length - 1)
				this.index = this.index + 1;
			this.render();
		},

		save : function() {
			this.nextQuestion();
			console.log(this.answers);
			$.ajax({
				type : "POST",
				url : "add_new",
				data : {
					quiz_response : JSON.stringify(this.answers),
					quiz_id : $.getUrlVar("quiz_id"),
					foo : "fee"
				},
				dataType : "json",
				success : function(data, status) {
					console.log(data);
					window.location.href = data.location;
				},
				error : function(data, status) {
					console.log("error - " + status);
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

	$.extend({
		getUrlVars : function() {
			var vars = [], hash;
			var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
			for (var i = 0; i < hashes.length; i++) {
				hash = hashes[i].split('=');
				vars.push(hash[0]);
				vars[hash[0]] = hash[1];
			}
			return vars;
		},
		getUrlVar : function(name) {
			return $.getUrlVars()[name];
		}
	});

	if (page == "quiz:create") {
		new QuizView();
	} else if (page == "quiz:answer") {
		new QuizAnswerView();
	} else if (page == "quiz:show") {
		new QuizView();
	} else if (page == "quiz_response:show") {
		new QuizView();
	}

	var quiz = [];

})(jQuery); 