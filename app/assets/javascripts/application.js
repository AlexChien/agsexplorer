// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
// require jquery
//= require jquery_ujs
//= require jquery.cookie
// require bootstrap-all
// require bootstrap-affix
// require scrollUp/lib/jquery.easing.min.js
// require scrollUp/jquery.scrollUp.js
// require_tree .

var ags = { s_date:[], neworks: ['btc', 'pts'], color_pts: '#4572A7', color_btc: '#99443E' };
var comify_re = /(\d{1,3})(?=(\d{3})+(?:$|\.))/g;

$(function(){
  // tabs activated by hover event
  $('.nav-tabs > li > a').hover( function(){
    $(this).tab('show');
  });

  // scrollUp
  $.scrollUp({
    scrollName: 'scrollUp', // Element ID
    topDistance: '200', // Distance from top before showing element (px)
    topSpeed: 300, // Speed back to top (ms)
    animation: 'fade', // Fade, slide, none
    animationInSpeed: 200, // Animation in speed (ms)
    animationOutSpeed: 200, // Animation out speed (ms)
    scrollText: '', // Text for element
    activeOverlay: false  // Set CSS color to display scrollUp active point, e.g '#00FFFF'
  });

  $('.tooltip').tooltip();

  // current time: utc
  setInterval(function(){
    $('#utc_now').html(utcNow());
  },1000);

  // calculate donation efficiency
  // calculateEfficiency(); setInterval(calculateEfficiency, 250000);

  // init balance_address init value
  if ($('#balance_address') && $.cookie('balance_address')) {
    var addrs = $.cookie('balance_address').split(',')
    $('#balance_address').val(addrs[0]);

    if (addrs.length > 1) {
      for (var i = 0; i < addrs.length; i++) {
        var li = $('<li><a href="/balances/'+addrs[i]+'">'+addrs[i]+'</a></li>').append(
          $('<button type="button" class="close" data-dismiss="alert" data-addr="'+addrs[i]+'">×</button>').click(function()
          {
            var addrs = $.cookie('balance_address').split(',');
            addrs.splice(addrs.indexOf($(this).data('addr')),1);
            $.cookie('balance_address', addrs.join(','), {path: '/'});
            $(this).parent().remove();
          })
        );
        $('#balance_lookup .history').append(li);
      }
    }
  }

  // symbolizable
  $('.overview .symolizable').click(changeSymbol);

  // balance form
  $('#balance_search_frm').submit(function( event ){
    var address = $('#balance_address').val();

    if (address) {
      $(this).attr('action', '/balances/'+address);
      var addrs = $.cookie('balance_address') || address;
      if (addrs.indexOf(address) == -1) {
        addrs += ',' + address;
      }
      $.cookie('balance_address', addrs, {path: '/'});
      return true;
    }

    event.preventDefault();
  });

  // notification form
  setup_notification_form();
});

function changeSymbol(){
  $('.overview .symolizable').each(function(){
    // btc
    if ($(this).data('type') == 'btc' && $('#btc_usd').data('value') != 0) {
      var cur = $(this).data('cur');
      if (cur == 'btc') {
        new_cur = 'usd';
        new_val = $('#btc_usd').data('value') * $(this).data('value') / 100000000;
      } else if (cur == 'usd'){
        new_cur = 'btc';
        new_val = $(this).data('value') / 100000000;
      }

      $(this).html(display_currency(new_val)).data('cur', new_cur);
    }

    // pts
    else if ($(this).data('type') == 'pts' && $('#pts_usd').data('value') != 0) {
      var cur = $(this).data('cur');
      if (cur == 'pts') {
        new_cur = 'usd';
        new_val = $('#pts_usd').data('value') * $(this).data('value') / 100000000;
      } else if (cur == 'usd'){
        new_cur = 'pts';
        new_val = $(this).data('value') / 100000000;
      }

      $(this).html(display_currency(new_val)).data('cur', new_cur);
    }

    // ags_btc
    else if ($(this).data('type') == 'ags_btc' && $('#btc_usd').data('value') != 0) {
      var cur = $(this).data('cur');
      if (cur == 'ags_btc') {
        new_cur = 'usd_ags';
        new_val = $('#btc_usd').data('value') / $(this).data('value') / 100000000;
      } else if (cur == 'usd_ags'){
        new_cur = 'ags_btc';
        new_val = $(this).data('value') / 100000000;
      }

      $(this).html(display_currency(new_val)).data('cur', new_cur);
    }

    // ags_btc
    else if ($(this).data('type') == 'ags_pts' && $('#pts_usd').data('value') != 0) {
      var cur = $(this).data('cur');
      if (cur == 'ags_pts') {
        new_cur = 'usd_ags';
        new_val = $('#pts_usd').data('value') / $(this).data('value') / 100000000;
      } else if (cur == 'usd_ags'){
        new_cur = 'ags_pts';
        new_val = $(this).data('value') / 100000000;
      }

      $(this).html(display_currency(new_val)).data('cur', new_cur);
    }
  });
}

function display_currency(val){
  parts = val.toString().split('.');
  return parts[0].replace(comify_re, "$1,") + '<small class="num">.'+max8(parts[1])+' '+String(new_cur).split('_').join(' / ').toUpperCase()+'</small>'
}

function max8(d){
  return String(d).substring(0,8);
}

function calculateEfficiency(data){
  if (data["last"]) {
    var btc_e = ags.price_btc * data.last / ags.price_pts;
    var pts_e = 1 / btc_e;

    $('#btc_e').html(Math.round(btc_e*100)+'%').addClass(btc_e>pts_e?'label-success':'label-important');
    $('#pts_e').html(Math.round(pts_e*100)+'%').addClass(pts_e>btc_e?'label-success':'label-important');
    $('#abbr_btc').attr('title', 'PTS_BTC: ' + data.last + ' ' + utcNow());
    $('#abbr_pts').attr('title', 'PTS_BTC: ' + data.last + ' ' + utcNow());
  }
}

function utcNow(){
  var now = new Date();
  return dd(now.getUTCFullYear()) + '-' + dd(now.getUTCMonth()+1) + '-' + dd(now.getUTCDate()) + ' ' + dd(now.getUTCHours()) + ':' + dd(now.getUTCMinutes()) + ':' + dd(now.getUTCSeconds());
}

function loadTickers(){
  // load pts_btc and calculate efficiency
  $.getJSON('/proxy/ticker/bter/pts_btc.json',{}, function(data){
    if (data["last"]) {
      // ticker panel
      $('#pts_btc').data('value', data.last).html(data.last);

      // efficiency calculation
      calculateEfficiency(data);

      calculatePtsUsd();
    }
  });

  $.getJSON('/proxy/ticker/bitstamp/btc_usd.json',{}, function(data){
      // ticker panel
      $('#btc_usd').data('value', data.last).html(data.last);

      calculatePtsUsd();
  });
}

function calculatePtsUsd(){
  if ($('#pts_btc').data('value') != 0 && $('#btc_usd').data('value') != 0) {
    value = ($('#pts_btc').data('value') * $('#btc_usd').data('value')).toFixed(2);
    $('#pts_usd').data('value', value).html(value);
  }
}

function drawChart(container, chart_data){
  $(container).highcharts('StockChart', {
    chart: {
      type: 'column'
    },

    rangeSelector : {
      buttons: [
      {
        type: 'week',
        count: 1,
        text: '1w'
      }, {
        type: 'month',
        count: 1,
        text: '1m'
      }, {
        type: 'month',
        count: 3,
        text: '3m'
      }, {
        type: 'year',
        count: 1,
        text: '1y'
      }, {
        type: 'all',
        text: 'All'
      }],
      selected : 0
    },

    title : {
      text : 'Daily Donation'
    },

    subtitle: {
      text: 'BTC vs PTS'
    },

    legend: {
      enabled: true
    },

    xAxis: {
      type: 'datetime',
      dateTimeLabelFormats: {
        second: '%Y-%m-%d<br/>%H:%M:%S',
        minute: '%Y-%m-%d<br/>%H:%M',
        hour: '%Y-%m-%d<br/>%H:%M',
        day: '%Y<br/>%m-%d',
        week: '%Y<br/>%m-%d',
        month: '%Y-%m',
        year: '%Y'
      }
    },

    yAxis: [{
        title: {
            text: 'BTC'
        },
        plotLines: [{
          value: chart_data["btc_avg"],
          width: 1,
          color: ags.color_btc,
          dashStyle: 'dash',
          label: {
            text: 'BTC Avg.',
            align: 'left',
            x: 20
          }
        }]
    }, {
        title: {
            text: 'PTS'
        },
        plotLines: [{
          value: chart_data["pts_avg"],
          width: 1,
          color: ags.color_pts,
          dashStyle: 'dash',
          label: {
            text: 'PTS Avg.',
            align: 'right',
            x: -20
          }
        }],
        opposite: true
    }],

    series : [{
      name : 'BTC',
      yAxis: 0,
      data : chart_data['btc'],
      color: ags.color_btc
    },{
      name : 'PTS',
      yAxis: 1,
      data : chart_data['pts'],
      color: ags.color_pts
    }],

    tooltip: {
      valueDecimals: 8
    }
  });
}

function dd(d){
  return d > 9 ? d : "0"+d;
}

function setup_notification_form(){
  $('#notification_form')
    .bind("ajax:beforeSend",  function(){
      var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      if (!re.test($(this).find('.email').val())){
        $(this).find('div.alert').removeClass('alert-success')
          .addClass('alert-error').html('Please check your email format.').show();
        return false;
      }
    })
    .bind('ajax:success', function(xhr, data, status){
      $(this).find('div.alert').removeClass('alert-error')
        .addClass('alert-success').html('Successfully subscribed.').show();
    })
    .bind('ajax:error', function(xhr, data, status){
      var errorMessage = 'Sorry, an error has occured, your subscription is unsuccessful, please try again later.';
      if (data.responseJSON.reason) {
        errorMessage = data.responseJSON.reason;
      }

      $(this).find('div.alert').removeClass('alert-success')
        .addClass('alert-error').html(errorMessage).show();
    })
}
