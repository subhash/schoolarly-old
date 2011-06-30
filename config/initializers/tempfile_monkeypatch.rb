require 'tempfile'

class Tempfile
  class << self
      def callback(data)  # :nodoc:
        pid = $$
        lambda{
    if pid == $$
      path, tmpfile, cleanlist = *data

      print "removing ", path, "..." if $DEBUG

      tmpfile.close if tmpfile && !tmpfile.closed?

      # keep this order for thread safeness
      File.unlink(path) if File.exist?(path)
      cleanlist.delete(path) if cleanlist

      print "done\n" if $DEBUG
    end
        }
      end
  end
end