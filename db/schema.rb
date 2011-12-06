# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111202140927) do

  create_table "abuses", :force => true do |t|
    t.string   "email"
    t.string   "title"
    t.string   "referer"
    t.string   "description"
    t.boolean  "confirmed",     :default => false
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
  end

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "action"
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["item_type", "item_id"], :name => "index_activities_on_item_type_and_item_id"

  create_table "aggregation_hierarchies", :id => false, :force => true do |t|
    t.integer "ancestor_id",   :null => false
    t.integer "descendant_id", :null => false
    t.integer "generations",   :null => false
  end

  add_index "aggregation_hierarchies", ["ancestor_id", "descendant_id"], :name => "index_aggregation_hierarchies_on_ancestor_id_and_descendant_id", :unique => true
  add_index "aggregation_hierarchies", ["descendant_id"], :name => "index_aggregation_hierarchies_on_descendant_id"

  create_table "aggregations", :force => true do |t|
    t.string   "name"
    t.decimal  "score",            :precision => 6, :scale => 2
    t.integer  "parent_id"
    t.decimal  "weightage",        :precision => 5, :scale => 2
    t.integer  "drop_lowest"
    t.boolean  "weighted_average",                               :default => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "aggregations", ["user_id"], :name => "user_id"

  create_table "assignments", :force => true do |t|
    t.integer  "post_id"
    t.integer  "rubric_id"
    t.decimal  "score",           :precision => 6, :scale => 2
    t.boolean  "has_submissions",                               :default => false
    t.datetime "due_date"
    t.date     "date"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["post_id"], :name => "post_id"
  add_index "assignments", ["rubric_id"], :name => "rubric_id"

  create_table "attachments", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "user_id"
    t.string   "doc_file_name"
    t.string   "doc_content_type"
    t.integer  "doc_file_size"
    t.datetime "doc_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["user_id"], :name => "user_id"

  create_table "attendances", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     :default => "accepted"
    t.boolean  "invitation", :default => false
  end

  create_table "bloggerships", :force => true do |t|
    t.integer  "blog_id"
    t.integer  "user_id"
    t.string   "rol",        :default => "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blogs", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 50
    t.string   "secret",       :limit => 50
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "commentable_type",               :default => "",    :null => false
    t.boolean  "approved",                       :default => false
    t.string   "name"
    t.string   "email"
    t.string   "url"
    t.boolean  "spam",                           :default => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "config", :force => true do |t|
    t.string   "key",        :default => "", :null => false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "config", ["key"], :name => "key", :unique => true

  create_table "criteria", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "rubric_id"
    t.integer  "position"
    t.decimal  "weightage",   :precision => 6, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "criteria", ["rubric_id"], :name => "rubric_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "events", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.time     "start_time"
    t.time     "end_time"
    t.string   "url"
    t.string   "venue"
    t.string   "venue_link"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "capacity",          :default => -1
    t.string   "venue_address"
    t.boolean  "site_wide",         :default => false
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.boolean  "moderated",         :default => false
    t.string   "recurrence"
    t.date     "until"
  end

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.boolean  "deletable",    :default => false
    t.string   "folder_type"
    t.integer  "lock_version", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "inviter_id"
    t.integer  "invited_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grade_rubric_descriptors", :force => true do |t|
    t.integer  "grade_id"
    t.integer  "rubric_descriptor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grade_rubric_descriptors", ["grade_id"], :name => "grade_id"
  add_index "grade_rubric_descriptors", ["rubric_descriptor_id"], :name => "rubric_descriptor_id"

  create_table "grades", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.decimal  "score",         :precision => 6, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grades", ["user_id"], :name => "user_id"
  add_index "grades", ["assignment_id"], :name => "assignment_id"

  create_table "group_hierarchies", :id => false, :force => true do |t|
    t.integer "ancestor_id",   :null => false
    t.integer "descendant_id", :null => false
    t.integer "generations",   :null => false
  end

  add_index "group_hierarchies", ["ancestor_id", "descendant_id"], :name => "index_group_hierarchies_on_ancestor_id_and_descendant_id", :unique => true
  add_index "group_hierarchies", ["descendant_id"], :name => "index_group_hierarchies_on_descendant_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "state"
    t.boolean  "private"
    t.boolean  "moderated",                        :default => false
    t.integer  "user_id"
    t.string   "activation_code",    :limit => 40
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "network_type"
    t.integer  "network_id"
    t.integer  "parent_id"
  end

  create_table "klasses", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "levels", :force => true do |t|
    t.string   "name"
    t.integer  "rubric_id"
    t.integer  "position"
    t.decimal  "points",     :precision => 6, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "levels", ["rubric_id"], :name => "rubric_id"

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.boolean  "moderator",                     :default => false
    t.string   "state"
    t.string   "activation_code", :limit => 40
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_readings", :force => true do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "content"
    t.integer  "folder_id"
    t.boolean  "is_read",      :default => false
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notices", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notices", ["user_id"], :name => "user_id"

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 50
    t.string   "secret",                :limit => 50
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "parents", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "photoset_id"
    t.integer  "position",           :default => 1
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "photoset_memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "photoset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photosets", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "main_photo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "privacy",       :default => 0
  end

  create_table "plugin_schema_migrations", :id => false, :force => true do |t|
    t.string "plugin_name"
    t.string "version"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "blog_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.datetime "published_at"
    t.string   "doc_file_name"
    t.string   "doc_content_type"
    t.integer  "doc_file_size"
    t.datetime "doc_updated_at"
    t.string   "shortId"
    t.string   "uuid"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "website"
    t.string   "blog"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.text     "dynamic_attributes"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.float    "average_rating"
    t.integer  "ratings_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["rateable_id", "rateable_type"], :name => "index_ratings_on_rateable_id_and_rateable_type"

  create_table "rubric_descriptors", :force => true do |t|
    t.text     "description"
    t.integer  "criterion_id"
    t.integer  "level_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rubric_descriptors", ["criterion_id"], :name => "criterion_id"
  add_index "rubric_descriptors", ["level_id"], :name => "level_id"

  create_table "rubrics", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rubrics", ["user_id"], :name => "user_id"

  create_table "schools", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shares", :force => true do |t|
    t.integer  "user_id"
    t.string   "shareable_type", :limit => 30
    t.integer  "shareable_id"
    t.string   "shared_to_type", :limit => 30
    t.integer  "shared_to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",                       :default => 1
  end

  create_table "smerf_forms", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "code",       :null => false
    t.integer  "active",     :null => false
    t.text     "cache"
    t.datetime "cache_date"
  end

  add_index "smerf_forms", ["code"], :name => "index_smerf_forms_on_code", :unique => true

  create_table "smerf_forms_users", :force => true do |t|
    t.integer "user_id",       :null => false
    t.integer "smerf_form_id", :null => false
    t.text    "responses",     :null => false
  end

  create_table "smerf_responses", :force => true do |t|
    t.integer "smerf_forms_user_id", :null => false
    t.string  "question_code",       :null => false
    t.text    "response",            :null => false
  end

  create_table "students", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subjects", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submissions", :force => true do |t|
    t.integer  "post_id"
    t.integer  "assignment_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "submissions", ["post_id"], :name => "post_id"
  add_index "submissions", ["user_id"], :name => "user_id"
  add_index "submissions", ["assignment_id"], :name => "assignment_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "teachers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_ratings", :force => true do |t|
    t.integer  "rating_id"
    t.integer  "user_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_ratings", ["user_id", "rating_id"], :name => "index_user_ratings_on_user_id_and_rating_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "activation_code",           :limit => 40
    t.string   "password_reset_code"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.string   "state",                                   :default => "passive"
    t.boolean  "admin",                                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "person_type"
    t.integer  "person_id"
  end

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "link"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weighted_assignments", :force => true do |t|
    t.integer  "assignment_id"
    t.integer  "aggregation_id"
    t.decimal  "weightage",      :precision => 5, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weighted_assignments", ["assignment_id"], :name => "assignment_id"
  add_index "weighted_assignments", ["aggregation_id"], :name => "aggregation_id"

  add_foreign_key "aggregations", ["user_id"], "users", ["id"], :name => "aggregations_ibfk_1"

  add_foreign_key "assignments", ["post_id"], "posts", ["id"], :name => "assignments_ibfk_1"
  add_foreign_key "assignments", ["rubric_id"], "rubrics", ["id"], :name => "assignments_ibfk_2"

  add_foreign_key "attachments", ["user_id"], "users", ["id"], :name => "attachments_ibfk_1"

  add_foreign_key "criteria", ["rubric_id"], "rubrics", ["id"], :name => "criteria_ibfk_1"

  add_foreign_key "grade_rubric_descriptors", ["grade_id"], "grades", ["id"], :name => "grade_rubric_descriptors_ibfk_1"
  add_foreign_key "grade_rubric_descriptors", ["rubric_descriptor_id"], "rubric_descriptors", ["id"], :name => "grade_rubric_descriptors_ibfk_2"

  add_foreign_key "grades", ["user_id"], "users", ["id"], :name => "grades_ibfk_1"
  add_foreign_key "grades", ["assignment_id"], "assignments", ["id"], :name => "grades_ibfk_2"

  add_foreign_key "levels", ["rubric_id"], "rubrics", ["id"], :name => "levels_ibfk_1"

  add_foreign_key "notices", ["user_id"], "users", ["id"], :name => "notices_ibfk_1"

  add_foreign_key "rubric_descriptors", ["criterion_id"], "criteria", ["id"], :name => "rubric_descriptors_ibfk_1"
  add_foreign_key "rubric_descriptors", ["level_id"], "levels", ["id"], :name => "rubric_descriptors_ibfk_2"

  add_foreign_key "rubrics", ["user_id"], "users", ["id"], :name => "rubrics_ibfk_1"

  add_foreign_key "submissions", ["post_id"], "posts", ["id"], :name => "submissions_ibfk_1"
  add_foreign_key "submissions", ["user_id"], "users", ["id"], :name => "submissions_ibfk_2"
  add_foreign_key "submissions", ["assignment_id"], "assignments", ["id"], :name => "submissions_ibfk_3"

  add_foreign_key "weighted_assignments", ["assignment_id"], "assignments", ["id"], :name => "weighted_assignments_ibfk_1"
  add_foreign_key "weighted_assignments", ["aggregation_id"], "aggregations", ["id"], :name => "weighted_assignments_ibfk_2"

end
