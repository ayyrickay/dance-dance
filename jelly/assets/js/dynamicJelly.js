/*
---------------------------------------
 Jellyfish!
-----------------------------------------
*/
var Jelly = function(color, x, y, rad) {
  this.color = color;
  this.x = x;
  this.y = y;
  this.init = function() {
    body = new paper.Path.Circle({
      center: new Point(this.x, this.y),
      radius: rad,
      strokeColor: color,
      strokeWidth: 3,
      fillColor: '#94d4d7',
      fullySelected: false
    });

    body.removeSegment(3); //from circle to blob


    var from = new Point(100, 600);
    var to = new Point(110, 600);
    path = new Path.Line(from, to);
    path.strokeColor = 'rgba(255,255,255,0.4)';

    var count = 5;
    var amount = 8;
    newLayer = new Layer();
    newLayer.activate();

    for (var j = 0; j < count; j++) {
      tentacle = new Path({
        strokeColor: color,
        strokeWidth: 3,
        strokeCap: 'round'
      });

      // Add 5 segment points to the path spread out
      // over the width of the view:
      xPosition = (x - rad + (j * 30));
      adjustment = 0.005 * Math.pow(xPosition - x ,2  )
      for (var i = 0; i <= amount; i++) {
        tentacle.add(new Point(xPosition, (y + i * 200 / amount) - adjustment +  10 ) );
      }
      tentacle.smooth();

      tentacle.fullySelected = false
      ;
    }
    newLayer.sendToBack();


  }


  this.jiggle = function (event) {
    var frequency = 4;
    var speed = -12;
    var colorChange = 30;

    var movement = 0.6 * Math.cos(event.time * frequency);
    var movementTopHandles = 0.6 * Math.cos(event.time * frequency -0.6);
    var movementTop = 0.6 * Math.cos(event.time * frequency -1.2);
    var movementSides = 0.6 * Math.cos(event.time * frequency + 0.4);
    var movementUP = 0.6 * Math.cos(event.time * frequency + 2);
        var topHandleA  = body.curves[0].handle2;
        var topHandleB  = body.curves[1].handle1;
        var rightHandle  = body.curves[0].handle1;
        var leftHandle  = body.curves[1].handle2;
        var A  = body.curves[0].point1;
        var B  = body.curves[2].point1;
        var top  = body.curves[1].point1;


        A.x += -2 * movementSides;
        B.x +=  2 * movementSides;

        for (var j = 0; j<5; j++){
          var item = newLayer.children[j];
          //item.strokeColor.hue += colorChange;

          // Loop through the segments of the path:
          for (var i = 0; i <= 8; i++) {
            var segment = item.segments[i];


            // A cylic value between -1 and 1
            var sinus =  2 * 0.6 * Math.cos(event.time * frequency + 0.4 - i/4);
            segment.point.x +=  sinus * (j-2) * .5;

            if (i == 0 && j == 0){
            path.hue
            path.add(new Point(item.position));
          }

          }
          item.smooth();
          if (movementUP > 0){
            item.position +=[0,  speed * movementUP];
          } else{
            item.position +=[0,  -movementUP];
          }
        }

        body.fillColor.hue = window.globals.magnitude;
        //body.strokeColor.hue += colorChange;


        top.y += movement * 2;
        topHandleA.x += 2* movementTopHandles;
        topHandleB.x += -2*movementTopHandles;


        if (movementUP > 0){
            body.position +=[0,  speed* movementUP];
        }else{
            body.position +=[0,  - movementUP];
          }
        //body.smooth();
        if (body.position.y <=-100){
          project.clear()
          j = new Jelly('#d5f3f6', 230, 520, 60);
        };
      view.draw();
  };
  this.init();
};


  var j = new Jelly('#d5f3f6', 250, 700, 60);

  function onFrame(event) {
    j.jiggle(event);
  };
