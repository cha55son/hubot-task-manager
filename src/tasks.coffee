# Description:
#   Simple per-channel task manager.
#
# Dependencies:
#   none
#
# Configurations:
#   none
#
# Commands:
#   hubot task list - List the tasks for this channel.
#   hubot task add <task title> - Add a task to this channel.
#   hubot task done <task number> - Mark a task as completed for this channel.
#   hubot task open <task number> - Re-open a task for this channel.
#   hubot task remove <task number> - Remove a task from this channel.
#   hubot task remove all - Remove all tasks from this channel.
#   list tasks - Alias for `hubot task list`
#   fixes|fixed|closes|closed #<task number> - Alias for `hubot done <task number>`
#
# Author:
#   Chason Choate (cha55son)

ROBOT = null
DATA = null
BRAIN_KEY = 'hubot-task-manager'

log = (level, msg) ->
  str = if typeof msg != 'string' then JSON.stringify(msg, null, 2) else msg
  ROBOT.logger[level]("#{BRAIN_KEY}: #{str}")
saveData = () ->
  ROBOT.brain.set BRAIN_KEY, DATA

# Task collection methods
getChannelTasks = (channelName) ->
  log 'debug', 'getChannelTasks()'
  channels = DATA.channels
  channels[channelName] = channels[channelName] || []
  channels[channelName]
setChannelTasks = (channelName, tasks) ->
  DATA.channels[channelName] = tasks
  saveData()

# Task methods
addChannelTask = (channelName, taskTitle) ->
  log 'debug', 'addChannelTask()'
  tasks = getChannelTasks channelName
  tasks.push({
    title: taskTitle,
    complete: false
  })
  saveData()
updateChannelTask = (channelName, taskIndex, params) ->
  task = getChannelTasks(channelName)[taskIndex]
  task.title = params.title if params.title
  task.complete = if typeof params.complete == 'undefined' then task.complete else params.complete == true
  saveData()
removeChannelTask = (channelName, taskIndex) ->
  tasks = getChannelTasks channelName
  tasks.splice(taskIndex, 1)
  saveData()

# Helper methods
listChannelTasks = (msg) ->
  tasks = getChannelTasks msg.message.room
  completed = tasks.filter (task) -> task.complete
  return msg.send "There are no tasks! Add one with `#{ROBOT.name} task add <task title>`." if tasks.length == 0
  percent = parseInt((completed.length / tasks.length) * 100)
  msg.send "#{completed.length} of #{tasks.length} tasks completed. #{percent}%"
  if percent == 100
    msg.send "Way to go gang! Want to start another list? Clear all the tasks with `#{ROBOT.name} task remove all`"
  for task, i in tasks
    complete = if task.complete == true then "✓" else " "
    index = if (i+1).toString().length == 1 then " #{i+1}" else i+1
    msg.send "#{index}: [#{complete}] #{task.title}"

module.exports = (robot) ->
  ROBOT = robot

  robot.brain.on 'loaded', ->
    DATA = robot.brain.get(BRAIN_KEY) || { channels: { } }

  robot.respond /tasks? list/i, (msg) ->
    listChannelTasks(msg)

  robot.hear /^list tasks?/i, (msg) ->
    listChannelTasks(msg)

  robot.respond /tasks? add (.+)$/i, (msg) ->
    addChannelTask(msg.message.room, msg.match[1])
    listChannelTasks(msg, msg.message.room)

  robot.respond /tasks? done ([0-9]+)/i, (msg) ->
    updateChannelTask(msg.message.room, msg.match[1] - 1, { complete: true })
    listChannelTasks(msg)

  robot.respond /tasks? open ([0-9]+)/i, (msg) ->
    updateChannelTask(msg.message.room, msg.match[1] - 1, { complete: false })
    listChannelTasks(msg)

  robot.hear /^(fixes|fixed|closes|closed) #?([0-9]+)/i, (msg) ->
    updateChannelTask(msg.message.room, msg.match[2] - 1, { complete: true })
    listChannelTasks(msg)

  robot.respond /tasks? remove ([0-9]+)/i, (msg) ->
    removeChannelTask(msg.message.room, msg.match[1] - 1)
    listChannelTasks(msg)

  robot.respond /tasks? remove all( confirm)?/i, (msg) ->
    tasks = getChannelTasks msg.message.room
    completed = tasks.filter (task) -> task.complete
    if completed.length == tasks.length || msg.match[1]
      DATA.channels[msg.message.room] = []
      saveData()
      msg.send "All tasks have been removed! Add more tasks with `#{ROBOT.name} task add <task title>`"
    else
      msg.send "There are incomplete tasks. Reply with `#{robot.name} task remove all confirm` to remove all tasks."
