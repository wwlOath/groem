require File.join(File.dirname(__FILE__),'..','spec_helper')

describe 'EM_GNTP::App #notify without callbacks' do

  describe 'with one notification' do
  
    before do
      @p_svr = DummyServerHelper.fork_server(:notify => '-OK')
      EM_GNTP::Client.response_class = MarshalHelper.dummy_response_class
      @subject = EM_GNTP::App.new('test', :port => DummyServerHelper::DEFAULT_PORT)
    end
    
    after do
      DummyServerHelper.kill_server(@p_svr)
    end

    it 'should receive back one OK response from notify' do
      count = 0
      
      @subject.register do
        notification 'hello' do end
      end
      
      @subject.notify('hello') do |resp|
        count += 1
        resp[0].to_i.must_equal 0
        count.must_equal 1
      end
      
    end
  end
 
  describe 'when notification hasnt been specified' do

    before do
      @p_svr = DummyServerHelper.fork_server(:notify => '-OK')
      EM_GNTP::Client.response_class = MarshalHelper.dummy_response_class
      @subject = EM_GNTP::App.new('test', :port => DummyServerHelper::DEFAULT_PORT)
    end
    
    after do
      DummyServerHelper.kill_server(@p_svr)
    end
  
    it 'should return nil' do
      
      @subject.register do
        notification 'hello' do end
      end
      
      @subject.notify('goodbye') do end.must_be_nil
      
    end
    
  end
   
end

module AppNotifyCallbacksHelper


  def should_receive_ok_and_callback(app, rslt, timeout)
    ok_count = 0
    click_count = 0
    close_count = 0
    timedout_count = 0
    
    EM.run {
      app.register do
        notification 'Foo' do |n|
          n.callback 'You', :type => 'shiny'
        end
      end
     
      app.when_callback 'CLICK' do |resp|
        puts "App received callback: #{resp[2]}"
        click_count += 1
        resp[2].must_equal 'CLICK'
      end
      
      app.when_callback 'CLOSE' do |resp|
        puts "App received callback: #{resp[2]}"
        close_count += 1
        resp[2].must_equal 'CLOSE'
      end
      
      app.when_callback 'TIMEDOUT' do |resp|
        puts "App received callback: #{resp[2]}"
        timedout_count += 1
        resp[2].must_equal 'TIMEDOUT'
      end
      
      app.notify('Foo') do |resp|
        ok_count += 1 if resp[0].to_i == 0
        resp[0].to_i.must_equal 0
      end
     
      EM.add_timer(timeout + 1) {
        ok_count.must_equal 1
        case rslt
        when 'CLICK'
          click_count.must_equal 1
          close_count.must_equal 0
          timedout_count.must_equal 0
        when 'CLOSE'
          click_count.must_equal 0
          close_count.must_equal 1
          timedout_count.must_equal 0
        when 'TIMEDOUT'
          click_count.must_equal 0
          close_count.must_equal 0
          timedout_count.must_equal 1
        end
        EM.stop
      }
      
    }
  end
  
end


describe 'EM_GNTP::App #notify with simple callbacks' do


  describe 'when CLICK callback returned' do
    include AppNotifyCallbacksHelper
    
    before do
      @p_svr = DummyServerHelper.fork_server(:callback => ['CLICK', 2])
      EM_GNTP::Client.response_class = MarshalHelper.dummy_response_class
      @subject = EM_GNTP::App.new('test', :port => DummyServerHelper::DEFAULT_PORT)
    end
    
    after do
      DummyServerHelper.kill_server(@p_svr)
    end    
    
    it 'should receive ok and CLICK callback' do
      should_receive_ok_and_callback(@subject, 'CLICK', 2)
    end
    
  end
  
  describe 'when CLOSE callback returned' do
    include AppNotifyCallbacksHelper
    
    before do
      @p_svr = DummyServerHelper.fork_server(:callback => ['CLOSE', 2])
      EM_GNTP::Client.response_class = MarshalHelper.dummy_response_class
      @subject = EM_GNTP::App.new('test', :port => DummyServerHelper::DEFAULT_PORT)
    end
    
    after do
      DummyServerHelper.kill_server(@p_svr)
    end    
    
    it 'should receive ok and CLOSE callback' do
      should_receive_ok_and_callback(@subject, 'CLOSE', 2)
    end
    
  end
  
  describe 'when TIMEDOUT callback returned' do
    include AppNotifyCallbacksHelper
    
    before do
      @p_svr = DummyServerHelper.fork_server(:callback => ['TIMEDOUT', 2])
      EM_GNTP::Client.response_class = MarshalHelper.dummy_response_class
      @subject = EM_GNTP::App.new('test', :port => DummyServerHelper::DEFAULT_PORT)
    end
    
    after do
      DummyServerHelper.kill_server(@p_svr)
    end    
    
    it 'should receive ok and TIMEDOUT callback' do
      should_receive_ok_and_callback(@subject, 'TIMEDOUT', 2)
    end
      
  end
  
end


describe 'EM_GNTP::App #notify with routed callbacks' do

end