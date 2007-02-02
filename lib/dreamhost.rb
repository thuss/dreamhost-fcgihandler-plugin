# Dreamhost RailsFCGIHandler mods so a kill -TERM doesn't kill your site while handling a request
class RailsFCGIHandler
 private
   def busy_exit_handler(signal)
     dispatcher_log :info, "busy: asked to terminate during request signal #{signal}, deferring!"
     @when_ready = :exit
   end

   # Dreamhost sends the term signal and if we are handling a request defer it
   def term_process_request(cgi)
     install_signal_handler('TERM',method(:busy_exit_handler).to_proc)
     Dispatcher.dispatch(cgi)
   rescue Exception => e  # errors from CGI dispatch
     raise if SignalException === e
     dispatcher_error(e)
   ensure
     install_signal_handler('TERM', method(:exit_now_handler).to_proc)
   end
   alias_method :process_request, :term_process_request
end