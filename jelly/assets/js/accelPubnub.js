/*
---------------------------------------
PubNub Information
-----------------------------------------
*/

var PUBNUB_accel = PUBNUB.init({
    //publish_key: 'Your Publish Key Here',
    subscribe_key: 'sub-c-c42b881a-9ae6-11e5-9a49-02ee2ddab7fe'
});

window.globals = {
  r: .5,
  g: .5,
  b: .5,
  magnitude: 0
};

// Subscribe to the demo_tutorial channel
console.log("Subscribing...")
PUBNUB_accel.subscribe({
  channel: 'p2-demo',
  message: function(m){
    console.log("Message Received: ")
    setWindowRGB(m);
    setWindowMagnitude(m);
  }
});

//function for describing accelerometer data in RGB
var setWindowRGB = function(accelData){
  var xyz = accelData["accel-xyz"];
  window.globals.r = xyz[0]/255;
  window.globals.g = xyz[1]/255;
  window.globals.b = xyz[2]/255;

  console.log('R:', window.globals.r, 'G:', window.globals.g, "B:", window.globals.b);
}


//function for describing the accelerometer data as magnitude
var setWindowMagnitude = function(accelData){
  var xyz = accelData["accel-xyz"];
  console.log(xyz);
  var squares = xyz.map(n => n*n);
  var total = squares.reduce((a,b) => a + b);

  console.log("Magnitude is: ", Math.sqrt(total));
  window.globals.magnitude = Math.sqrt(total);
};
