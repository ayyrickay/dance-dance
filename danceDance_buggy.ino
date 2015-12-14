#include <SPI.h>
#include <WiFi101.h>
#include <PubNub.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_ADXL345_U.h>
#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
  #include <avr/power.h>
#endif

#define PIN 6
Adafruit_NeoPixel strip = Adafruit_NeoPixel(60, PIN, NEO_GRB + NEO_KHZ800);

Adafruit_ADXL345_Unified accel = Adafruit_ADXL345_Unified(12345);

static char ssid[] = "CalVisitor";    // network SSID

char pubkey[] = "pub-c-8dcab5dd-7e8e-4db3-bf4f-52a77a5bfeae";
const static char subkey[] = "sub-c-c42b881a-9ae6-11e5-9a49-02ee2ddab7fe";
const static char channel[] = "p2-demo";

void displaySensorDetails(void)
{
  sensor_t sensor;
  accel.getSensor(&sensor);
  Serial.println("------------------------------------");
  Serial.print  ("Sensor:       "); Serial.println(sensor.name);
  Serial.print  ("Driver Ver:   "); Serial.println(sensor.version);
  Serial.print  ("Unique ID:    "); Serial.println(sensor.sensor_id);
  Serial.print  ("Max Value:    "); Serial.print(sensor.max_value); Serial.println(" m/s^2");
  Serial.print  ("Min Value:    "); Serial.print(sensor.min_value); Serial.println(" m/s^2");
  Serial.print  ("Resolution:   "); Serial.print(sensor.resolution); Serial.println(" m/s^2");  
  Serial.println("------------------------------------");
  Serial.println("");
  delay(500);
}

void displayDataRate(void)
{
  Serial.print  ("Data Rate:    "); 
  
  switch(accel.getDataRate())
  {
    case ADXL345_DATARATE_3200_HZ:
      Serial.print  ("3200 "); 
      break;
    case ADXL345_DATARATE_1600_HZ:
      Serial.print  ("1600 "); 
      break;
    case ADXL345_DATARATE_800_HZ:
      Serial.print  ("800 "); 
      break;
    case ADXL345_DATARATE_400_HZ:
      Serial.print  ("400 "); 
      break;
    case ADXL345_DATARATE_200_HZ:
      Serial.print  ("200 "); 
      break;
    case ADXL345_DATARATE_100_HZ:
      Serial.print  ("100 "); 
      break;
    case ADXL345_DATARATE_50_HZ:
      Serial.print  ("50 "); 
      break;
    case ADXL345_DATARATE_25_HZ:
      Serial.print  ("25 "); 
      break;
    case ADXL345_DATARATE_12_5_HZ:
      Serial.print  ("12.5 "); 
      break;
    case ADXL345_DATARATE_6_25HZ:
      Serial.print  ("6.25 "); 
      break;
    case ADXL345_DATARATE_3_13_HZ:
      Serial.print  ("3.13 "); 
      break;
    case ADXL345_DATARATE_1_56_HZ:
      Serial.print  ("1.56 "); 
      break;
    case ADXL345_DATARATE_0_78_HZ:
      Serial.print  ("0.78 "); 
      break;
    case ADXL345_DATARATE_0_39_HZ:
      Serial.print  ("0.39 "); 
      break;
    case ADXL345_DATARATE_0_20_HZ:
      Serial.print  ("0.20 "); 
      break;
    case ADXL345_DATARATE_0_10_HZ:
      Serial.print  ("0.10 "); 
      break;
    default:
      Serial.print  ("???? "); 
      break;
  }  
  Serial.println(" Hz");  
}

void displayRange(void)
{
  Serial.print  ("Range:         +/- "); 
  
  switch(accel.getRange())
  {
    case ADXL345_RANGE_16_G:
      Serial.print  ("16 "); 
      break;
    case ADXL345_RANGE_8_G:
      Serial.print  ("8 "); 
      break;
    case ADXL345_RANGE_4_G:
      Serial.print  ("4 "); 
      break;
    case ADXL345_RANGE_2_G:
      Serial.print  ("2 "); 
      break;
    default:
      Serial.print  ("?? "); 
      break;
  }  
  Serial.println(" g");  
}

void setup()
{
  Serial.begin(9600);
  Serial.println("Serial set up");

  /* Initialise the sensor */
  if(!accel.begin())
  {
    /* There was a problem detecting the ADXL345 ... check your connections */
    Serial.println("Ooops, no ADXL345 detected ... Check your wiring!");
    while(1);
  }

  /* Set the range to whatever is appropriate for your project */
  accel.setRange(ADXL345_RANGE_2_G);
  
  /* Display some basic information on this sensor */
  displaySensorDetails();
  
  /* Display additional settings */
  displayDataRate();
  displayRange();

   if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    while(true); // stop
  }

  int status;
  // attempt to connect to Wifi network:
  do {
    Serial.print("WiFi connecting to SSID: ");
    Serial.println(ssid);

    // Connect to the network
    status = WiFi.begin(ssid); // open network
  } while (status != WL_CONNECTED);
  Serial.println("WiFi set up");

  PubNub.begin(pubkey, subkey);
  Serial.println("PubNub set up");

  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
}

void loop()
{
  WiFiClient *client;

  sensors_event_t event; 
  accel.getEvent(&event);

  /* Display the results (acceleration is measured in m/s^2) */
  Serial.print("X: "); Serial.print(event.acceleration.x); Serial.print("  ");
  Serial.print("Y: "); Serial.print(event.acceleration.y); Serial.print("  ");
  Serial.print("Z: "); Serial.print(event.acceleration.z); Serial.print("  ");
  Serial.println("m/s^2 ");

  int accelData[3];
  
  int ledColors[3];
  if (event.acceleration.x < 0) {
    int xColor = ((event.acceleration.x * -1)*15);
    Serial.print("This is xColor: ");
    Serial.println(xColor);
    if (xColor > 255) {
        xColor = 255;
        ledColors[0] = xColor;
        accelData[0] = xColor;
      } else {
        ledColors[0] = xColor; 
        accelData[0] = xColor; 
      }
  } else {
    int xColor = ((event.acceleration.x)*15);
    Serial.print("This is xColor: ");
    Serial.println(xColor);
    if (xColor > 255) {
        xColor = 255;
        ledColors[0] = xColor;
        accelData[0] = xColor;
      } else {
        ledColors[0] = xColor;
        accelData[0] = xColor;  
      } 
  }
  if (event.acceleration.y < 0) {
    int yColor = ((event.acceleration.y * -1)*15);
    Serial.print("This is yColor: ");
    Serial.println(yColor);
    if (yColor > 255) {
        yColor = 255;
        ledColors[1] = yColor;
        accelData[1] = yColor;
      } else {
        ledColors[1] = yColor;
        accelData[1] = yColor;  
      }
  } else {
    int yColor = ((event.acceleration.y)*15);
    Serial.print("This is yColor: ");
    Serial.println(yColor);
    if (yColor > 255) {
        yColor = 255;
        ledColors[1] = yColor;
        accelData[1] = yColor;
      } else {
        ledColors[1] = yColor;
        accelData[1] = yColor;  
      } 
  }
  if (event.acceleration.z < 0) {
    int zColor = ((event.acceleration.z * -1)*15);
    Serial.print("This is zColor: ");
    Serial.println(zColor);
    if (zColor > 255) {
        zColor = 255;
        ledColors[2] = zColor;
        accelData[2] = zColor;
      } else {
        ledColors[2] = zColor;
        accelData[2] = zColor;  
      }
  } else {
    int zColor = ((event.acceleration.z)*15);
    Serial.print("This is zColor: ");
    Serial.println(zColor);
    if (zColor > 255) {
        zColor = 255;
        ledColors[1] = zColor;
        accelData[2] = zColor;
      } else {
        ledColors[1] = zColor;
        accelData[2] = zColor;
      } 
  }

  char msg[64] = "{\"accel-xyz\":[";
  for (int i = 0; i < 3; i++) {
    sprintf(msg + strlen(msg), "%d", accelData[i]);
    if (i < 2)
      strcat(msg, ",");
  }
  strcat(msg, "]}");

  Serial.print("publishing message: ");
  Serial.println(msg);
  client = PubNub.publish(channel, msg);
  if (!client) {
    Serial.println("publishing error");
  } else {
    client->stop();
  }
  
  for(int i=0;i<30;i++){
    strip.setPixelColor(i, strip.Color(ledColors[0],ledColors[1],ledColors[2]));
    strip.show(); // This sends the updated pixel color to the hardware.
  }
  
  Serial.print("This is ledColor[0]: ");
  Serial.println(ledColors[0]);
  Serial.print("This is ledColor[1]: ");
  Serial.println(ledColors[1]);
  Serial.print("This is ledColor[2]: ");
  Serial.println(ledColors[2]);
}
