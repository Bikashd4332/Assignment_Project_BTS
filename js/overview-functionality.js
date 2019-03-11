window.onload = function() {
let openChart = new CanvasJS.Chart("open-chart", {
  theme: "light2", // "light1", "light2", "dark1", "dark2"
  exportEnabled: false,
  animationEnabled: false,
  data: [{
    type: "pie",
    startAngle: 25,
    toolTipContent: "<b>{label}</b>: {y}%",
    showInLegend: false,
    dataPoints: [
      { y: 51.08, label: "Opened Reports" },
      { y: 10.62, label:"Others"}
    ]
  }]
});
openChart.render();

let inProgressChart = new CanvasJS.Chart("in-progress-chart", {
  theme: "light2", // "light1", "light2", "dark1", "dark2"
  exportEnabled: false,
  animationEnabled: false,
  data: [{
    type: "pie",
    startAngle: 25,
    toolTipContent: "<b>{label}</b>: {y}%",
    showInLegend: false,
    dataPoints: [
      { y: 51.08, label:"In Progress Reports"},
      { y: 10.62, label:"Others" }
    ]
  }]
});
inProgressChart.render();


let closedChart = new CanvasJS.Chart("closed-chart", {
  theme: "light2", // "light1", "light2", "dark1", "dark2"
  exportEnabled: false,
  animationEnabled: false,
  data: [{
    type: "pie",
    startAngle: 25,
    toolTipContent: "<b>{label}</b>: {y}%",
    showInLegend: false,
    dataPoints: [
      { y: 51.08, label:"Closed Reports"},
      { y: 10.62, label:"Others"}
    ]
  }]
});
closedChart.render();


};
