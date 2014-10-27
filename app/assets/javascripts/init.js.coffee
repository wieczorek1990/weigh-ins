alertify.defaults.glossary.title = I18n.t('weigh-ins')

$.fn.bootstrapDP = $.fn.datepicker.noConflict()

$.fn.validator = ->
  this.bootstrapValidator {
    submitButtons: 'button[type="submit"]',
    fields: {
      weight: {
        validators: {
          numeric: {
            separator: window.decimalPoint
          }
        }
      },
      date: {
        validators: {
          date: {
            format: 'YYYY-MM-DD'
          }
        }
      }
    }
  }
  return this

$.isDate = (string) ->
  try
    $.datepicker.parseDate('yy-mm-dd', string)
    return true
  catch
    return false

window.decimalPoint = I18n.defaultSeparator
window.separatorRegExp = new RegExp('\\t+| +|;')
window.fb = new Firebase("https://weighins.firebaseio.com/users/username/weigh-ins")

window.getWeighIns = (callback) ->
  window.fb.once 'value', (weighInsSnapshot) ->
    weighIns = weighInsSnapshot.val()
    callback(weighIns)
  , (error) ->
    fbError error

window.getDates = (callback) ->
  window.getWeighIns (weighIns) ->
    dates = []
    for date of weighIns
      dates.push(date)
    callback(dates)

window.addWeighIn = (date, weight, usedDates) ->
  unless $.isDate(date) and $.isNumeric(weight)
    console.log('error: incorrect data')
    return false
  for usedDate in usedDates
    if date is usedDate
      return date
  window.fb.child(date).set(parseFloat(weight))
  return true

window.fbError = (error) ->
  console.log('firebase error: ' + error.code)
