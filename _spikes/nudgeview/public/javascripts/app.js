$(document).ready(function(){ 
  $("#inside").svg();
  var svg = $("#inside").svg('get');
  function d(){
    $.post('/', 
      function(data){
        svg.add($(data))
      }
    );
  };
  window.setInterval(d, 200)
});