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
  data.addColumn('number', 'X');
  data.addColumn('number', 'Dogs');
  data.addColumn('number', 'Cats');

  data.addRows([
    [0, 0, 0],
    [1, 10, 5],
    [2, 23, 15],
    [3, 17, 9],
    [4, 18, 10],
    [5, 9, 5],
    [6, 11, 3],
    [7, 27, 19],
    [8, 33, 25],
    [9, 40, 32],
    [10, 32, 24],
    [11, 35, 27]
  ]);

  var options = {
    hAxis: {
      title: 'Months'
    },
    vAxis: {
      title: 'Counters'
    },
    colors: ['#a52714', '#097138']
  };

  const chart = new google.visualization.LineChart(document.getElementById('chart_div'));
  chart.draw(data, options);
}