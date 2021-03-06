require 'eventmachine'

module Groem

  class App < Struct.new(:host, :port, 
                         :environment, :headers, :notifications)
    include Groem::Marshal::Request
    
    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = 23053
    DEFAULT_ENV = {'protocol' => 'GNTP', 'version' => '1.0',
                   'request_method' => 'REGISTER', 'encryption_id' => 'NONE'
                  }
                  
    def initialize(name, opts = {})
      self.environment, self.headers, self.notifications = {}, {}, {}
      self.environment = DEFAULT_ENV.merge(opts.delete(:environment) || {})
      self.host = opts.delete(:host) || DEFAULT_HOST
      self.port = opts.delete(:port) || DEFAULT_PORT
      self.headers[GNTP_APPLICATION_NAME_KEY] = name
      opts.each_pair {|opt, val| self.headers[growlify_key(opt)] = val }
    end
    
    # used by Marshal::Request#dump
    def [](key)
      to_request[key]
    end
    
    def name; self.headers[GNTP_APPLICATION_NAME_KEY]; end
    
    def register(&blk)
      if blk.arity == 1
        blk.call(self)
      else
        instance_eval(&blk)
      end
      send_register
    end
    
    def notify(name, *args, &blk)
      return unless n = self.notifications[name]
      opts = ((Hash === args.last) ? args.pop : {})
      title = args.shift
      n = n.dup    # copies attributes so not overwritten
      n.title = title ? title : self.name
      if cb = opts.delete(:callback)
        n.callback(cb) 
      end
      opts.each_pair {|k, v| n.__send__ :"#{k}=", v}
      send_notify(n, &blk)
    end
    
    def notification(name, *args)
      n = Groem::Notification.new(name, *args)
      yield(n) if block_given?
      n.application_name = self.name
      self.notifications[name] = n
    end
   
    def callbacks &blk
      if blk.arity == 1
        blk.call(self)
      else
        instance_eval(&blk)
      end      
    end
        
    def header(key, value)
      self.headers[growlify_key(key)] = value
    end
    
    def icon(uri_or_file)
      # TODO if not uri
      header GNTP_APPLICATION_ICON_KEY, uri_or_file
    end
    
    def binary(key, value_or_io)
      #TODO
    end
    
    #---- callback definition methods
    
    def when_register &blk
      @register_callback = blk
    end
    
    def when_register_failed &blk 
      @register_errback = blk
    end
    
    def when_click path=nil, &blk
      when_callback GNTP_CLICK_CALLBACK_RESULT, path, &blk
    end
    
    def when_close path=nil, &blk
      when_callback GNTP_CLOSE_CALLBACK_RESULT, path, &blk
    end
    
    def when_timedout path=nil, &blk
      when_callback GNTP_TIMEDOUT_CALLBACK_RESULT, path, &blk
    end
    
    def when_callback action, path=nil, &blk
      action = growlify_action(action)
      path = \
        case path
        when String
          [path, nil]
        when Hash
          [path[:context], path[:type]]
        end
      #puts "App defined callback: #{action} #{path.inspect}"      
      notify_callbacks[Groem::Route.new(action, path)] = blk
    end
    
        
    def to_request
      {'environment' => self.environment, 
       'headers' => self.headers, 
       'notifications' => notifications_to_register
      }
    end
    
   protected
        
    def register_callback; @register_callback; end
    def register_errback; @register_errback || register_callback; end

    def notify_callbacks; @notify_callbacks ||= {}; end

    def send_register
      Groem::Client.response_class = Groem::Response
      stop_after = !(EM.reactor_running?)
      ret = nil
      EM.run {
        connect = Groem::Client.register(self, host, port)
        connect.callback do |resp| 
          EM.stop if stop_after
        end
        connect.errback  do |resp| 
          register_errback.call(resp) if register_errback
          ret = resp
          EM.stop if stop_after
        end
        connect.when_ok do |resp| 
          register_callback.call(resp) if register_callback
          ret = resp
        end
      }
      ret
    end
    
    def send_notify(notif, &blk)
      Groem::Client.response_class = Groem::Response
      stop_after = !(EM.reactor_running?)
      ret = nil
      EM.run {
        connect = Groem::Client.notify(notif, host, port)
        connect.callback do |resp| 
          EM.stop if stop_after
        end
        connect.errback do |resp| 
          yield(resp) if block_given?
          ret = resp
          EM.stop if stop_after
        end
        connect.when_ok do |resp|
          yield(resp) if block_given?
          ret = resp
        end
        connect.when_callback do |resp|
          route_response(resp)
       end
      }
      ret
    end
    
    def notifications_to_register
      self.notifications.inject({}) do |memo, pair|
        memo[pair[0]] = pair[1].to_register
        memo
      end
    end
        
    def route_response(resp)
      #puts "Response callback route: #{resp.callback_route.inspect}"
      notify_callbacks.sort.each do |route, blk|
        #puts "Checking against pattern: #{route.pattern.inspect} => #{route.matches?(resp.callback_route).inspect}"
        if route.matches?(resp.callback_route)
          blk.call(resp)
        end
      end
    end
    
  end
  
end