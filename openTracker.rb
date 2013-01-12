require "rubygems"
require "bundler/setup"
require 'eventmachine'
require 'win32/api'
require 'time'
require 'csv'
require 'sys/proctable'
require 'yaml'

include Sys
include Win32

class TimeTracker
  TWO_MINUTES = 120000
  def initialize
    puts "Time Tracker started"
    @trackingHash = Hash.new
    @GetForegroundWindow = API.new('GetForegroundWindow', 'V', 'L', 'user32')
    @GetLastInputInfo    = API.new('GetLastInputInfo', 'P', 'I', 'user32')
    @GetTickCount        = API.new('GetTickCount', 'V', 'L', 'kernel32')
    @GetWindowThreadProcessId = API.new('GetWindowThreadProcessId', 'LP', 'L', 'user32')
    @Programs = loadProgramNames
    checkForLogs
    loadTrackingHash
  end

  def checkForLogs
    # Check for existence of logs folder
    Dir.mkdir('logs') unless File.directory?('logs')
  end

  def loadTrackingHash 
    #YAML OUTPUT
    #filename = "logs/#{getDay}-#{getMonth}-#{getYear}.yaml"
    #if File.exists?(filename)
      #@trackingHash = YAML.load_file(filename).to_hash
    #end

    #If program is being resumed for the day, re-load trackingHash with contents from CSV file.
    filename = ("logs/#{getDay}-#{getMonth}-#{getYear}.csv")
    if File.exists?(filename)
      arr_of_arrs = CSV.read(filename)
      arr_of_arrs.each do |part|
        @trackingHash[part[0]] = part[1].to_i
      end
    end  
  end
  
  def loadProgramNames
    if File.exists?('programs.yaml')
      programs = YAML.load_file('programs.yaml')
    end
  end

  def getDay
    t= Time.now
    t.day
  end

  def getMonth
    t= Time.now
    if t.month < 10 
      return "0#{t.month}"
    else
      return t.month 
    end
  end

  def getYear
    t=Time.now
    t.year
  end

  def writetoLogs
    #YAML OUTPUT
    #filename = ("logs/#{getDay}-#{getMonth}-#{getYear}.yaml")  
    #File.open(filename,'w') {|f| f.write(@trackingHash.to_yaml)}

    filename = ("logs/#{getDay}-#{getMonth}-#{getYear}.csv")
    begin
      CSV.open(filename, "wb") do |csv|
        @trackingHash.each do |program, time|
          csv << [program,time]
        end
      end
    rescue Errno::EACCES  
      puts "File is currently in use by another application. Could not succesfully write log data."
    end
  end

  def getLastInput
    buf = [8,0].pack('l*')
    @GetLastInputInfo.call(buf)
    lastInput = buf.unpack('l*')
    return lastInput
  end

  def getWindowThreadProcessId(hwnd)
    buf = [8,0].pack('l*')
    @GetWindowThreadProcessId.call(hwnd,buf)
    lastInput = buf.unpack('l*')
    return lastInput
  end

  def updateProcessName(processName)

    if @Programs.has_key?(processName)
      return @Programs[processName]
    else
      return processName
    end
  end

  def resetCheck
  #Resest Tracking Hash at midnight
    t = Time.now
    if t.hour == 0 and t.min == 0 and t.sec == 0
      @trackingHash.clear
    end
  end

  def getTickCount
    @GetTickCount.call
  end
  def run
    EventMachine.run do
     EventMachine.add_periodic_timer(1) do
      previousInput = Tracker.getLastInput[1]
      currentTick = Tracker.getTickCount
      resetCheck
      if (currentTick - previousInput) < TWO_MINUTES
        hwnd = @GetForegroundWindow.call
        pid = getWindowThreadProcessId(hwnd)[0]       
        process = ProcTable.ps(pid)
        unless process.nil?
          processName = process.comm.to_s
          processName = updateProcessName(processName)
        end
        if @trackingHash.has_key?(processName)
          @trackingHash[processName] += 1
        else
          @trackingHash[processName] = 1
        end
        Tracker.writetoLogs
      end
    end
  end
end
end


Tracker = TimeTracker.new
Tracker.run

