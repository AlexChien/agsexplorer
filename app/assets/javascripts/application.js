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
//= require jquery
//= require jquery_ujs
//= require bootstrap-all
//= require bootstrap-affix
//= require scrollUp/lib/jquery.easing.min.js
//= require scrollUp/jquery.scrollUp.js
// require_tree .

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
  })

  // current time: utc
  setInterval(function(){
    var now = new Date();
    str = dd(now.getUTCFullYear()) + '-' + dd(now.getUTCMonth()) + '-' + dd(now.getUTCDate()) + ' ' + dd(now.getUTCHours()) + ':' + dd(now.getUTCMinutes()) + ':' + dd(now.getUTCSeconds());
    $('#utc_now').html(str);
  },1000);

  // draw charts
  if ($('body').attr('id') == 'home') {
    drawChart('#btc-chart-container', 'btc', []);
    drawChart('#pts-chart-container', 'pts', []);
  }

});

function drawChart(container, network, data){
  $(container).highcharts({
    title: {
      text: 'Daily Investment: ' + network.toUpperCase(),
      x: -20 //center
    },
    xAxis: {
      categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    },
    yAxis: {
      title: {
        text: 'Amount Invested (' + network.toUpperCase() + ')'
      },
      plotLines: [{
        value: 0,
        width: 1,
        color: '#808080'
      }]
    },
    tooltip: {
      valueSuffix: '°C'
    },
    legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'middle',
      borderWidth: 0
    },
    series: [{
      name: 'Daily Avg. Investment',
      data: [9,9,9,9,9,9,9,9,9,9,9,9]
    }, {
      name: 'Investment',
      data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]
    }]
  });
}

function dd(d){
  return d > 9 ? d : "0"+9;
}

var copyToClipboard = function(from_selector){
  if(window.clipboardData && window.clipboardData.setData){
    window.clipboardData.setData('text', $(from_selector).val());
  }else{
    alert("您的浏览器不支持此复制功能，请使用Ctrl+C或鼠标右键。");
    $(from_selector).select(); // 选中要复制的内容，给用户提供方便
  }
}
