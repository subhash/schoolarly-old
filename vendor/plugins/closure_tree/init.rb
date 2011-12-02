require 'closure_tree/acts_as_tree'

ActiveRecord::Base.send :extend, ClosureTree::ActsAsTree
ActiveRecord::Base.send :include, ClosureTree::Model::ClassMethods
ActiveRecord::Base.send :include, ClosureTree::Model::InstanceMethods


