### hubot-task-manager

A simple script that keeps a checked list of items for different channels.
Users in a channel can create/mark/remove items as needed so everyone is on the same page.

### Usage

```
> hubot help
...
fixes|fixed|closes|closed #<task number> - Alias for `hubot done <task number>`
hubot task add <task title> - Add a task to this channel.
hubot task done <task number> - Mark a task as completed for this channel.
hubot task list - List the tasks for this channel.
hubot task open <task number> - Re-open a task for this channel.
hubot task remove <task number> - Remove a task from this channel.
hubot task remove all - Remove all tasks from this channel.
list tasks - Alias for `hubot task list`
...
```

### Installation

```
npm install --save hubot-task-manager
vim external-scripts.json
# ..., "hubot-task-manager"]
# Start your bot!
```

### Development

```
git clone ...
cd hubot-task-manager
npm link
cd <some repo that uses this script>
npm link hubot-task-manager
```
