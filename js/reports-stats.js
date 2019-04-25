$(document).ready(function () {
  google.charts.load('current', {
    packages: ['corechart', 'line']
  });
  google.charts.setOnLoadCallback(drawLineColors);
});

/**
 * @description This function is called when google charts is loaded on the document.
 */
function drawLineColors() {
  const data = new google.visualization.DataTable();
  data.addColumn('string', 'X');
  data.addColumn('number', 'Open');
  data.addColumn('number', 'Close');
  
  var options = {
    hAxis: {
      title: 'Months'
    },
    vAxis: {
      title: 'Counters'
    },
    colors: [ '#097138', '#a52714']
  };

  const chart = new google.visualization.LineChart(document.getElementById('chart_div'));

  $.ajax({
    url: '../CFCs/ReportsComponent.cfc',
    data: {
      method: 'GetAllStatsZipped'
    }
  }).done(function (response) {
    const responseInJson = JSON.parse(response);
    data.addRows(responseInJson);
    chart.draw(data, options);
  });


}