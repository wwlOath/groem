require File.join(File.dirname(__FILE__),'..','spec_helper')

describe 'EM_GNTP::Marshal::Request.load' do

  #------ REGISTER requests --------#
  
  describe 'when valid REGISTER request with one notification and no binaries' do
    
    before do
      @input = <<-__________
GNTP/1.0 REGISTER NONE
Application-Name: SurfWriter 
Application-Icon: http://www.site.org/image.jpg 
X-Creator:  Apple Software 
X-Application-ID:08d6c05a21512a79a1dfeb9d2a8f262f 
 Notifications-Count: 1 

Notification-Name: Download Complete 
Notification-Display-Name: Download completed 
Notification-Enabled:True 
X-Language : English 
 X-Timezone: PST 


__________
      dummy = Class.new { include(EM_GNTP::Marshal::Request) }
      @subject = dummy.load(@input, false)
    end
    
    it 'should return a hash with keys for environment, headers, and notifications' do
      @subject.has_key?('environment').must_equal true
      @subject.has_key?('headers').must_equal true
      @subject.has_key?('notifications').must_equal true
    end
    
    it 'environment hash should have version == 1.0' do
      @subject['environment']['version'].must_equal '1.0'
    end

    it 'environment hash should have request_action == REGISTER' do
      @subject['environment']['request_action'].must_equal 'REGISTER'
    end
    
    it 'headers hash should have application_name == SurfWriter' do
      @subject['headers']['application_name'].must_equal 'SurfWriter'
    end
    
    it 'headers hash should have notifications_count == 1' do
      @subject['headers']['notifications_count'].must_equal '1'
    end
    
    it 'headers hash should have x_application_id == 08d6c05a21512a79a1dfeb9d2a8f262f' do
      @subject['headers']['x_application_id'].must_equal '08d6c05a21512a79a1dfeb9d2a8f262f'
    end
    
    it 'notifications hash should have 1 key' do
      @subject['notifications'].keys.size.must_equal 1
    end
    
    it 'notifications hash should have key \'Download Complete\'' do
      @subject['notifications']['Download Complete'].wont_be_nil
    end
    
    it '\'Download Complete\' notification should have notification_display_name == \'Download completed\'' do
      @subject['notifications']['Download Complete']['notification_display_name'].must_equal 'Download completed'
    end
    
    it '\'Download Complete\' notification should have notification_enabled == \'True\'' do
      @subject['notifications']['Download Complete']['notification_enabled'].must_equal 'True'
    end
    
    it '\'Download Complete\' notification should have x_timezone == \'PST\'' do
      @subject['notifications']['Download Complete']['x_timezone'].must_equal 'PST'
    end
    
    it '\'Download Complete\' notification should have x_language == \'English\'' do
      @subject['notifications']['Download Complete']['x_language'].must_equal 'English'
    end
    
    it 'headers hash should not have x_timezone key' do
      @subject['headers'].has_key?('x_timezone').must_equal false
    end
    
  end
    
  describe 'when valid REGISTER request with three notifications and no binaries' do
    
    before do
      @input = <<-__________
GNTP/1.0 REGISTER NONE
Application-Name: SurfWriter 
Application-Icon: http://www.site.org/image.jpg 
X-Creator: Apple Software 
X-Application-ID: 08d6c05a21512a79a1dfeb9d2a8f262f 
Notifications-Count: 3 

Notification-Name: Download Complete 
Notification-Display-Name: Download completed 
Notification-Enabled: True 
X-Language: English 
X-Timezone: PST 

Notification-Name: Download Started 
Notification-Display-Name: Download starting 
Notification-Enabled: False 
X-Timezone: GMT 

Notification-Name: Download Error 
Notification-Display-Name: Error downloading 
Notification-Enabled: True 
X-Language: Spanish 

__________
      dummy = Class.new { include(EM_GNTP::Marshal::Request) }
      @subject = dummy.load(@input, false)
    end
    
    it 'should return a hash with keys for environment, headers, and notifications' do
      @subject.has_key?('environment').must_equal true
      @subject.has_key?('headers').must_equal true
      @subject.has_key?('notifications').must_equal true
    end
      
    it 'notifications hash should have 3 keys' do
      @subject['notifications'].keys.size.must_equal 3
    end
    
    it 'notifications hash should have key \'Download Complete\'' do
      @subject['notifications']['Download Complete'].wont_be_nil
    end

    it 'notifications hash should have key \'Download Started\'' do
      @subject['notifications']['Download Started'].wont_be_nil
    end
    
    it 'notifications hash should have key \'Download Error\'' do
      @subject['notifications']['Download Error'].wont_be_nil
    end

    it '\'Download Complete\' notification should have notification_display_name == \'Download completed\'' do
      @subject['notifications']['Download Complete']['notification_display_name'].must_equal 'Download completed'
    end

    it '\'Download Started\' notification should have notification_enabled == \'False\'' do
      @subject['notifications']['Download Started']['notification_enabled'].must_equal 'False'
    end    
    
    it '\'Download Error\' notification should have x_language == \'Spanish\'' do
      @subject['notifications']['Download Error']['x_language'].must_equal 'Spanish'
    end    

    it '\'Download Started\' notification should not have x_language key' do
      @subject['notifications']['Download Started'].has_key?('x_language').must_equal false
    end    
    
    it '\'Download Error\' notification should not have x_timezone key' do
      @subject['notifications']['Download Error'].has_key?('x_timezone').must_equal false
    end    
    
  end
  
  describe 'when valid REGISTER request with one binary referenced once in headers' do
  
  end
  
  describe 'when valid REGISTER request with one binary referenced once in notifications' do
  
  end

  describe 'when valid REGISTER request with three binaries referenced once each in headers and notifications' do
  
  end
  
  describe 'when valid REGISTER request with three binaries referenced twice each in headers and notifications' do
  
  end
  
  
  #------ NOTIFY requests --------#
  
  describe 'when valid NOTIFY request with no binaries' do
    
    before do
      @input = <<-__________
GNTP/1.0 NOTIFY NONE
Application-Name: SurfWriter 
Notification-Name: Download Complete
Notification-ID: 999
Notification-Title:XYZ finished downloading
 Notification-Sticky: True
Notification-Icon : http://www.whatever.com/poo.jpg

__________
      dummy = Class.new { include(EM_GNTP::Marshal::Request) }
      @subject = dummy.load(@input, false)
    end

    it 'should return a hash with keys for environment, headers, and notifications' do
      @subject.has_key?('environment').must_equal true
      @subject.has_key?('headers').must_equal true
      @subject.has_key?('notifications').must_equal true
    end
    
    it 'environment hash should have version == 1.0' do
      @subject['environment']['version'].must_equal '1.0'
    end

    it 'environment hash should have request_action == NOTIFY' do
      @subject['environment']['request_action'].must_equal 'NOTIFY'
    end
    
    it 'headers hash should have application_name == SurfWriter' do
      @subject['headers']['application_name'].must_equal 'SurfWriter'
    end
    
    it 'headers hash should have notification_title == \'XYZ finished downloading\'' do
      @subject['headers']['notification_title'].must_equal 'XYZ finished downloading'
    end

    it 'headers hash should have notification_sticky == \'True\'' do
      @subject['headers']['notification_sticky'].must_equal 'True'
    end
    
    it 'headers hash should have notification_icon == \'http://www.whatever.com/poo.jpg\'' do
      @subject['headers']['notification_icon'].must_equal 'http://www.whatever.com/poo.jpg'
    end
    
    it 'notifications hash should be empty' do
      @subject['notifications'].empty?.must_equal true
    end

  end
  
  describe 'when valid NOTIFY request with one binary referenced once' do
  
  end

  describe 'when valid NOTIFY request with three binaries referenced once each' do
  
  end
  
  describe 'when valid NOTIFY request with three binaries referenced twice each' do
  
  end
  
end



#---------- dump -----------#
  
module MarshalRequestDumpHelper

  def self.dummy_request(env = {}, hdrs = {}, notifs = {})
    klass = Class.new { 
              include(EM_GNTP::Marshal::Request) 
              require 'forwardable'
              extend Forwardable
              def_delegators :@raw, :[], :[]=
              def raw; @raw ||= {}; end
              def initialize(input = {})
                @raw = input
              end
            }
    klass.new({'environment' => env, 'headers' => hdrs, 'notifications' => notifs})
  end
  
end


describe 'EM_GNTP::Marshal::Request#dump' do
  
  describe 'when valid REGISTER request with one notification, no binaries' do
    
    before do
      @input_env = { 'protocol' => 'GNTP',
                     'version' => '1.0',
                     'request_action' => 'REGISTER',
                     'encryption_id' => 'NONE'
                    }
      @input_hdrs = {'application_name' => 'SurfWriter',
                     'application_icon' => 'http://www.site.org/image.jpg'
                    }
      @input_notifs = { 'Download Complete' => {
                            'notification_display_name' => 'Download completed',
                            'notification_enabled' => 'True',
                            'x_language' => 'English',
                            'x_timezone' => 'PST'
                        }
                      }

      @subject = MarshalRequestDumpHelper.dummy_request(
                   @input_env, @input_hdrs, @input_notifs).dump
    end
    
    it 'should output a string' do
      @subject.class.must_be_same_as String
      puts; puts @subject
    end
    
    it 'should output 10 lines terminated by CRLF' do
      lines = @subject.split("\r\n")
      lines.size.must_equal 10
    end
    
    it 'should output the first line as the standard GNTP first header' do
      lines = @subject.split("\r\n")
      lines[0].must_match(/^#{@input_env['protocol']}\/#{@input_env['version']}\s+#{@input_env['request_action']}\s+#{@input_env['encryption_id']}\s*$/i)
    end
    
    it 'should output the notification count == count of input notifications' do
      @subject.must_match(/^\s*notification-count\s*:\s*#{@input_notifs.keys.count}\s*$/i)
    end
    
    it 'should have a notification-name line for each input notification' do
      @input_notifs.each_pair do |name, pairs|
        @subject.must_match(/^\s*notification-name\s*:\s*#{name}\s*$/i)
      end
    end
    
  end
  
  describe 'when no environment' do
  
  end
    
end