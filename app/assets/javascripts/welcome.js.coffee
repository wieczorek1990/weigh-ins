# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

chart = null
validator = null

pad = (num, size = 2) ->
  s = '0' + num
  return s.substr(s.length - size)

unpackWeighInSnapshot = (weighInSnapshot) ->
  date = weighInSnapshot.name()
  weight = weighInSnapshot.val()
  return [date, weight]

getMillis = (date) ->
  return (new Date(date)).valueOf()

getPoint = (date, weight) ->
  return {
    x: getMillis(date),
    y: weight,
    date: date
  }

getIndex = (series, date) ->
  for point, index in series.data
    if point.date is date
      return index
  return -1

formatDate = (date) ->
  year = pad(date.getFullYear(), 4)
  month = pad(date.getMonth() + 1)
  day = pad(date.getDate())
  return [year, month, day].join('-')

today = ->
  return formatDate(new Date())

submit = ->
  validator.validate()
  if validator.isValid()
    weight = $('#weight').val()
    date = $('#date').val()
    dates = []
    for point in chart.get('you').data
      dates.push(point.date)
    result = window.addWeighIn(date, weight, dates)
    if typeof result is 'string'
      alertify.alert(I18n.t('already-weighed-in') + result)

$ ->
  if window.locale isnt 'en'
    Highcharts.setOptions {
      lang: {
        decimalPoint: window.decimalPoint,
        loading: I18n.t('highcharts-loading'),
        months: $.fn.bootstrapDP.dates[window.locale].months,
        noData: I18n.t('highcharts-noData'),
        printChart: I18n.t('highcharts-printChart'),
        resetZoomTitle: I18n.t('highcharts-reset-zoom-title'),
        shortMonths: $.fn.bootstrapDP.dates[window.locale].monthsShort,
        thousandsSep: ' ',
        weekdays: $.fn.bootstrapDP.dates[window.locale].days
      }
    }

  $('#addForm').validator()
  validator = $('#addForm').data('bootstrapValidator')
  $('#date').bootstrapDP {
    format: 'yyyy-mm-dd',
    autoclose: true,
    language: window.locale
  }
  $('#date').bootstrapDP('update', today())
  validator.validate()

  $('#weight, #date').keypress (event) ->
    if event.keyCode is 13
      submit()
  $('#submit').click ->
    submit()

  chart = new Highcharts.Chart {
    chart: {
      renderTo: 'container'
    },
    series: [{
      id: 'you',
      name: I18n.t('you')
      animation: false
    }],
    title: {
      text: I18n.t('weigh-ins')
    },
    xAxis: {
      title: {
        text: I18n.t('date')
      },
      type: 'datetime'
    },
    yAxis: {
      title: {
        text: I18n.t('weight')
      }
    }
  }

  window.fb.once 'value', (weighInsSnapshot) ->
    data = []
    weighInsSnapshot.forEach (weighInSnapshot) ->
      [date, weight] = unpackWeighInSnapshot(weighInSnapshot)
      data.push(getPoint(date, weight))
      return
    chart.showLoading()
    chart.get('you').setData(data)
    chart.hideLoading()

    # TODO don't know why it fires on page load
    window.fb.on 'child_added', (weighInSnapshot) ->
      [date, weight] = unpackWeighInSnapshot(weighInSnapshot)
      series = chart.get('you')
      index = getIndex(series, date)
      if index is -1
        series.addPoint(getPoint(date, weight))
    , (error) ->
      window.fbError(error)

    window.fb.on 'child_changed', (weighInSnapshot) ->
      [date, weight] = unpackWeighInSnapshot(weighInSnapshot)
      series = chart.get('you')
      index = getIndex(series, date)
      series.data[index].update(weight)
    , (error) ->
      window.fbError(error)

    window.fb.on 'child_removed', (weighInSnapshot) ->
      date = weighInSnapshot.name()
      series = chart.get('you')
      index = getIndex(series, date)
      if index > -1
        series.data[index].remove()
    , (error) ->
      window.fbError(error)

  , (error) ->
    window.fbError(error)
