require 'logger'

# Static class representing logger for a simple navigation
class ProcessLogger
	# logger instance
	@@logger = nil
	# logging process switch
	@@log_activities = false

	# Static method to construct logger
	def self.construct(filename)
		@@logger = Logger.new(filename)
		@@log_activities = true

		# very simple looger format
		@@logger.formatter = proc do |severity, datetime, progname, msg|
   			"OSM_SN: #{msg}\n"
		end		
	end

	# Add message to a log file
	def self.log(msg)
		if @@log_activities
			@@logger.info(msg)
		end
	end

	# Return logger
	def self.logger
		@@logger
	end
end