/*
---------------------------------------
PubNub Information
-----------------------------------------
*/

var currentMag = null,
    pastMag = null;

var PUBNUB_accel = PUBNUB.init({
    //publish_key: 'Your Publish Key Here',
    subscribe_key: 'sub-c-c42b881a-9ae6-11e5-9a49-02ee2ddab7fe'
});

window.globals = {
  magnitude: 0
};

// Subscribe to the demo_tutorial channel
console.log("Subscribing...")
PUBNUB_accel.subscribe({
  channel: 'p2-demo',
  message: function(m){
    console.log(
      "Message Received." + '<br>' +
      "Message:" + accelMagnitude(m));
      window.globals.magnitude = accelMagnitude(m);
    }
});

//function for describing the accelerometer data as magnitude
var accelMagnitude = function(accelData){
  console.log(accelData)
  var xyz = accelData["accel-xyz"];
  var squares = xyz.map(n => n*n);
  console.log(squares);
  var total = squares.reduce((a,b) => a + b);
  console.log(total);

  console.log(Math.sqrt(total));
  return Math.sqrt(total)
};
