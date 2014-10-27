# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

replaceForm = ($tr, template, args = {}) ->
  html = HandlebarsTemplates[template](args)
  $tr.find('td.date, td.weight').remove()
  $tr.find('td.index').after(html)

editClick = (event) ->
  $edit = $(this)
  $edit.toggleClass('btn-danger')
  $edit.text(I18n.t('save'))
  $edit.unbind('click')
  $edit.click ->
    save($tr, date, weight)
  $tr = $edit.parents('tr')
  date = $tr.children('td.date').text()
  weight = $tr.children('td.weight').text()
  replaceForm($tr, 'form')
  $tr.find('input[name="date"]').val(date)
  $tr.find('input[name="weight"]').val(weight)
  $tr.find('input').keypress (event) ->
    if event.keyCode is 13
      save($tr, date, weight)
  $tr.validator()
  validator = $tr.data('bootstrapValidator')
  validator.validate()

deleteClick = ->
  $delete = $(this)
  $tr = $delete.parents('tr')
  date = $tr.children('td.date').text()
  window.fb.child(date).remove ->
    $.when($tr.remove()).then ->
      $indexes = $('td.index')
      $indexes.each (index) ->
        $(this).text(index + 1)
      if $('tbody').children().length is 0
        html = HandlebarsTemplates['no-data']
        $('#data').html(html)

save = ($tr, oldDate, oldWeight) ->
  validator = $tr.data('bootstrapValidator')
  validator.validate()
  unless validator.isValid()
    alertify.alert(I18n.t('validation-error'))
    return
  date = validator.getFieldElements('date').val()
  weight = parseFloat(validator.getFieldElements('weight').val())
  validator.destroy()
  replaceForm($tr, 'no-form', { date: date, weight: weight })
  $edit = $tr.find('button.edit')
  $edit.toggleClass('btn-danger')
  $edit.text(I18n.t('edit'))
  $edit.unbind('click')
  $edit.click editClick
  if oldDate isnt date
    window.fb.child(oldDate).remove ->
      window.fb.child(date).set(weight)
  else
    if oldWeight isnt weight
      window.fb.child(date).set(weight)

$ ->
  Handlebars.registerHelper 't', (key) ->
    return I18n.t(key)
  Handlebars.registerHelper 'plusOne', (number) ->
    return number + 1
  Handlebars.registerPartial 'no-data', HandlebarsTemplates['no-data']
  $spinner = $('body')
  $spinner.spin()
  window.fb.on 'value', (weighInsSnapshot) ->
    weighIns = weighInsSnapshot.val()
    html = HandlebarsTemplates['data']({ weighIns: weighIns })
    $('#data').html(html)
    $('.edit').click editClick
    $('.delete').click deleteClick
    $spinner.spin(false)
