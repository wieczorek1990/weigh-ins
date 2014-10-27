# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

importText = (text) ->
  weighIns = []
  lines = text.split('\n')
  lines = $.grep(lines, (line) -> line)
  for line in lines
    [date, weight] = line.split(window.separatorRegExp)
    unless $.isDate(date) and $.isNumeric(weight)
      alertify.alert(I18n.t('import-error') + line)
      return
    weighIns.push({ date: date, weight: weight })
  window.getDates (dates) ->
    badDates = []
    for weighIn in weighIns
      result = window.addWeighIn(weighIn.date, weighIn.weight, dates)
      if result isnt true and typeof result is 'string'
        badDates.push(result)
    if badDates.length is 0
      alertify.alert(I18n.t('success'))
    else
      message = I18n.t('already-weighed-in') + badDates.join(', ')
      if weighIns.length isnt badDates.length
        message += '<br/>' + I18n.t('rest-imported')
      alertify.alert message, -> location.reload(true)

importAction = ->
  text = $('#import').val()
  importText(text)

importFileAction = (e) ->
  text = e.target.result
  importText(text)

saveData = (data, filename) ->
  $a = $('<a></a>')
  $('body').append($a)
  $a.attr('style', 'display: none')
  blob = new Blob([data], { type: 'text/plain'})
  url = window.URL.createObjectURL(blob)
  $a.attr('href', url)
  $a.attr('download', filename)
  $a[0].click()
  window.URL.revokeObjectURL(url)
  $a.remove()

exportAction = ->
  window.getWeighIns (weighIns) ->
    result = ''
    for date, weight of weighIns
      result += date + '\t' + weight + '\n'
    saveData(result + '\n', 'weigh-ins.txt')

$ ->
  $('#file-input').fileReaderJS {
    readAsDefault: "Text",
    on: {
      load: importFileAction
    }
  }
  $('#submitImport').click ->
    importAction()
  $('#submitExport').click ->
    exportAction()
