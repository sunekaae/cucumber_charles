# ensure that properties has been set; from support/charles_properties.rb
raise "@@charles_output_dir not defined" if !defined? @@charles_output_dir
raise "@@license_name not defined" if !defined? @@license_name
raise "@@license_key not defined" if !defined? @@license_key
raise "@@charlesCommand not defined" if !defined? @@charlesCommand

def charlesVerboseLogging string
  puts string
end

@@charles_file_name = "charles_#{Time.now.to_i}.chls" # generate a filename
charlesVerboseLogging("@@charles_file_name: #{@@charles_file_name}")
charlesVerboseLogging("current dir #{Dir.pwd}")

#Around( '@charles' ) do | scenario, block |
#  ensureCharlesIsRunning()
#  block.call
#  addCharlesLinkToReport()
#  #charles_support_exit
#end

When /^I start Charles$/ do
  startCharlesWithFork()
end

When /^I start Charles with Applescript$/ do
  value = startCharlesWithApplescript
  sleep 10.0 # wait a while; on first start this takes ~5-10 seconds. on subsequent starts it's more like ~3 seconds
  value.should() == true
end

When /^I stop Charles and save session$/ do
  value = charles_support_exit
  value.should() == true
end

When /^I enable automatic Charles$/ do
  charles_support_instantiate()
  @currentTestRunInfo.set_use_charles(true)
end

When /^I ensure that Charles is in foreground$/ do
  cmd = "osascript applescript/foreground.scpt"
  value = runCommandline(cmd)
  value.should() == "Charles"
end

When /^I ensure that Charles is running$/ do
  ensureCharlesIsRunning()
end

When /^I ask which app is in the foreground$/ do
  cmd = "osascript applescript/foreground.scpt"
  value = runCommandline(cmd)
  value
end

Then /^I verify that Charles is running$/ do
  isCharlesRunning().should() == true
end

Then /^I try something$/ do
  puts doesFileDoesExist "temp.chls"
end

When /^I make some example network calls$/ do
  runCommandline("curl --proxy localhost:8888 --insecure -v http://www.google.com ")
  runCommandline("curl --proxy localhost:8888 --insecure -v https://www.google.com ")
  runCommandline("curl --proxy localhost:8888 --insecure -v http://www.yahoo.com ")
  runCommandline("curl --proxy localhost:8888 --insecure -v http://www.bing.com ")
  runCommandline("curl --proxy localhost:8888 --insecure -v https://www.bing.com ")
end

def startCharlesWithFork
  raise "Charles already running" if isCharlesRunning()
  prepareCharlesConfig()
  configFile = File.join(Dir.pwd,"charles.config")
  charlesVerboseLogging("configFile: #{configFile}")
  job1 = fork do
    cmd = "#{@@charlesCommand} -config #{configFile}"
    runCommandline(cmd)
  end
  Process.detach(job1)
  # note: this returns immediately; charles app will take a while to launch...
  sleep 10.0
  addCharlesLinkToReport()
end

def addCharlesLinkToReport
  hyperlink = "<a href=\"#{@@charles_file_name}\">Charles Log</a>"
  puts hyperlink
end

def charles_support_instantiate
  charlesVerboseLogging( "ensuring that Charles is running" )
  ensureCharlesIsRunning()
  hyperlink = "<a href=\"#{@@charles_file_name}.chls\">Charles Log</a>"
  puts hyperlink
  com.nike.msp.Utils.USE_PROXY = true
end

def charles_support_exit
  raise "no point in trying to exit charles because it is not running" if !isCharlesRunning()
  charlesVerboseLogging("looks like charles is in use. will try to stop")
  charlesVerboseLogging ("charles filename: #{@@charles_file_name}")
  value = stopCharles(@@charles_file_name)
  sleep 2.0
  raise "Charles is still running; something went wrong trying to exit and save it." if isCharlesRunning() # charles shouldn't be running anymore. If it is, someting went wrong with the charles process. Mark as fail.
  # possibly insist on killing charles if still running, eg
  # http://hintsforums.macworld.com/showthread.php?t=79878
  # kill -HUP `ps -axwwwww | grep 'Charles' | grep -v grep | awk '{print $1}'`
  value
end

def isCharlesRunning
  cmd = "osascript applescript/is_charles_running.scpt"
  value = runCommandline(cmd)
  bool = toBool(value)
  charlesVerboseLogging( "is charles running: #{bool}" )
  bool
end

def toBool boolAsString
  return true if boolAsString == "true"
  return false if boolAsString == "false"
  raise "could parse to bool"
end


def startCharlesWithApplescript
  cmd = "osascript applescript/start_charles.scpt"
  value = runCommandline(cmd)
  #  value = system( cmd )
  sleep 5.0
  value
end

def ensureCharlesIsRunning
  if (!isCharlesRunning()) then
    startCharlesWithFork()
  end
end

def stopCharles partialFilename
  puts "stopCharles, partialFilename: #{partialFilename}"
  charlesVerboseLogging( "stopping charles..." )
  if doesFileDoesExist(partialFilename) then
    puts "file already exists; will not be able to save/replace. exiting..."
    return false
  end
  value = true #default to success
  if (isCharlesRunning()) then
    # nasty hack to get the path right when saving; even though the path is specific in the current dir as part of charles.config
    # ... is seems that Charles default to user's home dir, if charles.config is outside of the user's dir, eg when doing a CI build
    # so, need to input a path in the save dialog. But, seems that Charles doesn't accept an absolute path, like /Users ... so, need to use relative to back
    # out to root. Fortunately, seems that just adding a bunch of them will land you at root ... so, do a bunch of the, and add the path on top ...
    charlesFullPathAndName = File.join("../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../..", @@charles_output_dir, partialFilename)

    # nasty workaround above to get around not being able to just pass in something like /User/sune ... charles will append it's current working :-/
#    getBackToRoot = "../../../../../../../../../../../../.."
#    pathAndFileNameFromRoot = "#{Dir.pwd}/report/#{partialFilename}"
#    cmd = "osascript applescript/stop_charles.scpt #{getBackToRoot}#{pathAndFileNameFromRoot}"
    cmd = "osascript applescript/stop_charles.scpt #{charlesFullPathAndName}"
    charlesVerboseLogging( "will execute command: #{cmd}" )
    value = system( cmd )
    sleep 3.0
    
    isItRunning = isCharlesRunning()
    if (isItRunning == "true") then value = false end
    if (!isItRunning == "false" ) then value = true end
  end
  charlesVerboseLogging( "stop charles returning with value #{value}" )
  value
end

def runCommandline command
  charlesVerboseLogging("runCommandline will execute: #{command}")
  value = %x[ #{command} ]
  value = value.strip! # value is returned with trailing \n ... remove it with strip!
  return value
end

def doesFileDoesExist filename
  File.exist?(filename)
end

def prepareCharlesConfig
  charlesVerboseLogging("preparing Charles configuration file...")

  template = "charles.template.config"
  config = "charles.config"

  charlesVerboseLogging("OUTPUT_DIR: #{@@charles_output_dir}")
  charlesVerboseLogging("LICENSE_NAME: #{@@license_name}")
  charlesVerboseLogging("LICENSE_KEY: #{@@license_key}")

  text = File.read(template)
  replace = text.gsub(/{OUTPUT_DIR}/, @@charles_output_dir)
  replace = replace.gsub(/{LICENSE_NAME}/, @@license_name)
  replace = replace.gsub(/{LICENSE_KEY}/, @@license_key)
  File.open(config, "w") {|file| file.puts replace}
  charlesVerboseLogging("finished setup of Charles configuration file...")
end

#startCharlesWithFork()

at_exit do
  # stop charles, if it's running.
  charles_support_exit() if isCharlesRunning()
end

#AfterConfiguration do |config|
#  addCharlesLinkToReport()
#end