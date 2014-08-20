class RestartTaskWidget
  active: false

  constructor: ->
    @tasks = {}

  appendTo: (@$container) ->

  createTask: (host) ->
    new LightsTaskView(@$container, host)

  getTask: (host) ->
    @tasks[host] ||= @createTask(host)

  addHeading: ->
    @$headingEl = $("<h2 class='task-group-heading'></h2>")
    @$headingEl.appendTo(@$container)

  activate: ->
    return if @active
    @addHeading()
    @$headingEl.text(@heading)
    @active = true

  finish: ->
    return unless @active
    @$headingEl.text(@heading + " \u2713") # add check mark
    @$container.append("<div style='clear:both;'></div>")
    @active = false

  update: (text) ->
    parser = new CapistranoParser(text)
    unless @active
      res = parser.findTaskStart(@capistranoTask)
      return unless res
      @activate()

    @parse(parser)

    if parser.findTaskEnd(@capistranoTask)
      @finish()
    null


class ContainersRestartWidget extends RestartTaskWidget
  constructor: ->
    super
    @heading = "Restarting Servers"
    @capistranoTask = "deploy:restart"

  parse: (parser) ->
    parser.eachMessage (log) =>
      if match = log.output.match(/\[(\d+)\/(\d+)\] Restarting/)
        @getTask(log.host).update
          numPending: match[1]
          numLights: match[2]
      else if match = log.output.match(/\[(\d+)\/(\d+)\] Successfully Restarted/)
        @getTask(log.host).update
          numDone: match[1]
          numLights: match[2]
      else if match = log.output.match(/\[(\d+)\/(\d+)\] Unable to restart/)
        @getTask(log.host).update(numPending: match[1], numLights: match[2]).fail()
    null


class JobServersRestartWidget extends RestartTaskWidget
  constructor: ->
    super
    @heading = "Restarting Job Servers"
    @capistranoTask = "jobs:restart"

  createTask: (host) ->
    new JobServerRestartTaskView(@$container, host)

  parse: (parser) ->
    parser.eachMessage (log) =>
      if match = log.output.match(/sv-multi sending graceful_quit to (\d+) services/)
        @getTask(log.host).update
          numLights: match[1]
      else if match = log.output.match(/ok: run: ([\-\w\d]+): \(pid \d+\)/)
        task = @getTask(log.host)
        task.addStatus("up", match[1])
        task.update {}
      else if match = log.output.match(/Timeout: ([\-\w\d]+) still running after (\d+) seconds|timeout: run: ([\-\w\d]+): \(pid \d+\) (\d+)s/)
        task = @getTask(log.host)
        task.addStatus("partial", "timeout (#{match[2]||match[4]}s): #{match[1]||match[3]}")
        task.update {}
      else if match = log.output.match(/(fatal|fail|down):( run:)? ([\-\w\d]+)/)
        task = @getTask(log.host)
        task.addStatus("down", "#{match[1]}: #{match[3]}")
        task.update {}
    null


class LightsTaskView
  TEMPLATE = $.trim """
    <div class="task-lights">
      <span class="task-lights-text">
        <span class="task-lights-title"></span>
      </span>
      <span class="task-lights-boxes"></span>
    </div>
  """
  numLights: 0
  numPending: 0
  numDone: 0

  constructor: (@$container, host) ->
    @$element = $(TEMPLATE)
    @$title = host.split('.')[0]
    @$element.find('.task-lights-title').text(@$title)
    @insertSorted(@$element, @$title)

  insertSorted: (toInsert, title) ->
    inserted = false
    $('.task-lights',@$container).each ->
      title2 = $('.task-lights-title',this).text()
      # Sort shorter names first, so that the sort ends up 
      # like [sb1,sb2,sb10] not [sb1,sb10,sb2]
      if title2.length > title.length || (title2 > title && title2.length == title.length)
        toInsert.insertBefore(this)
        inserted = true
        return false
    toInsert.appendTo(@$container) unless inserted

  genBoxes: ->
    boxes = document.createDocumentFragment();
    for i in [1..(+@numLights)]
      status = if i <= @numDone
        'up'
      else if i <= @numPending
        'partial'
      else
        'neutral'
      $('<span>').addClass("task-lights-box box-#{status}").appendTo(boxes)
    boxes

  update: (attrs) ->
    $.extend(this, attrs)
    @$element.find('.task-lights-boxes').empty().append(@genBoxes())
    this

  fail: ->
    @$element.addClass('task-failed')

class JobServerRestartTaskView extends LightsTaskView
  constructor: (container, host) ->
    super container, host
    @$element.addClass("task-job-server")
    @statuses = []

  genBoxes: ->
    boxes = document.createDocumentFragment();
    for status in @statuses
      box = $('<span>').addClass("task-lights-box box-#{status[0]}")
      box.attr('title',status[1])
      box.appendTo(boxes)
    for i in [0...(@numLights-@statuses.length)]
      $('<span>').addClass("task-lights-box box-neutral").appendTo(boxes)
    boxes

  addStatus: (status, note) ->
    @statuses.push([status, note])

restartWidget = new ContainersRestartWidget()
jobRestartWidget = new JobServersRestartWidget()

ChunkPoller.prependFormatter (chunk) ->
  restartWidget.update(chunk)
  jobRestartWidget.update(chunk)
  false

Sidebar.registerPlugin(restartWidget)
Sidebar.registerPlugin(jobRestartWidget)