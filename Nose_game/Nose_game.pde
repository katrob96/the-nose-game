// Import OSC
import oscP5.*;
import netP5.*;

// Import Runway library
import com.runwayml.*;

// Runway Host
String runwayHost = "127.0.0.1";

// Runway Port
int runwayPort = 57100;

OscP5 oscP5;
NetAddress myBroadcastLocation;

JSONObject data;

PFont f; //Text font
float nX = 45.0;
float nY = 100.0;
boolean winner; //indicates that the ball has reached the goal, the game has been won
int diagonal = 30; //green circle weight and height
boolean start_position = true; //put the ball in the start

void setup () { 
  size (600, 400);
  OscProperties properties = new OscProperties();
  properties.setRemoteAddress("127.0.0.1", 57200);
  properties.setListeningPort(57200);
  properties.setDatagramSize(99999999);
  properties.setSRSP(OscProperties.ON);
  oscP5 = new OscP5(this, properties);
  // Use the localhost and the port 57100 that we define in Runway
  myBroadcastLocation = new NetAddress(runwayHost, runwayPort);
  connect();
  
  f = createFont("Arial", 50);  //Text font and size
  textFont(f);
}

void draw (){
  background(0);
  
  stroke(0, 0, 255);
  strokeWeight(10);
  line (30, 50, 220, 50);
  line (30, 150, 100, 150);
  line (100, 150, 100, 350);
  line (220, 50, 220, 250);
  line (100, 350, 500, 350);
  line (220, 250, 380, 250);
  line (380, 50, 380, 250);
  line (380, 50, 570, 50);
  line (500, 150, 570, 150);
  line (500, 350, 500, 150);
 
  //////// Extract the X and Y coordinates of the nose /////////////
  if (data!=null){                                 // ensures that empty data is not read
    JSONArray poses = data.getJSONArray("poses");  // the "poses" of the received data are saved
    if (poses.size()>0) {                          // make sure that the "poses" information is not empty (nose out of the camara)
      JSONArray keypoints = poses.getJSONArray(0); // stores "keypoints" found in the "poses" (0 = first data) structure
      JSONArray nose = keypoints.getJSONArray(0);  // stores the nose data (0 = first data) found in "keypoints"
      nX=width*nose.getFloat(0);                   // stores the first data of "nose" (X coordinate) 
      nY=height*nose.getFloat(1);                  // stores the second data of "nose" (Y coordinate)
    }    
  }
 
  ///////// CODE THAT DRAWS CIRCLES BASED ON THE STATE OF THE GAME ///////////
  if (start_position == true) {   //When it is active:
    draw_green_circle_start();    //draws green ball in start position
    draw_red_point_moving();      //draws the red point moving
  }
  else {                          //When it is inactive, the state of game is playing,
    draw_green_circle_moving();   //so, draws the green ball moving
  }
  
  ///////// CODE THAT DETECTS THAT THE GAME HAS TO START /////////////
  if ( (nX>30) && (nX<100) && ((nY>50)&&(nY<150)) ) {  //If nose position is in the Start quadrant:       
    start_position = false;                            //state of the game is playing
    winner = false;                                    //and resets the boolean 'winner'                 
  }
  
  ////////// CHECKING IF THE NOSE POSITION GETS OUT OF THE WAY (BY QUADRANTS) //////////////
          // (if the nose position is out, then it is activated the boolean start_position)
  
  // QUADRANT 1 (START)
  if ( (nX<100)  &&  ((nY<50)||(nY>150)) ) {            
    start_position = true;
  }   
  // QUADRANT 2
  else if ( ((nX>100)&&(nX<220)) &&((nY<50)||(nY>350)) ) {          
    start_position = true;
  }
  // QUADRANT 3
  else if ( ((nX>220)&&(nX<380)) &&((nY<250)||(nY>350)) ) {          
    start_position = true;  
  }
  // QUADRANT 4
  else if ( ((nX>380)&&(nX<500)) &&((nY<50)||(nY>350)) ) {          
    start_position = true;  
  }
  // QUADRANT 5 (WINNER)
  else if ( ((nX>500)&&(nX<570)) &&((nY<50)||(nY>150)) ) {          
    start_position = true;   
  }
 
  ////////// CODE THAT DETECTS THAT THE GAME HAS BEEN WON ///////////////            
  if ((start_position == false) && ((nX>550)&&(nX<600)) && ((nY>50)&&(nY<150)) ) { //If the ball is in the winning quadrant:
    winner = true;         //activates boolean 'winner' (the game has been won)    
    start_position = true; //and activates the return to the start position
  }   
  
  ////////// FORMAT OF "WINNER" IN CASE THE GAME HAS BEEN WON //////////
  if (winner == true) {
    fill(0, 255, 0);
    text("WINNER", 200, 315);
  }
}

// DRAWS THE STATIC GREEN CIRCLE (BALL) IN THE START POSITION
void draw_green_circle_start() {
  noStroke();
  fill(0, 255, 0);
  ellipse(45, 100, diagonal, diagonal);
}

// DRAWS THE GREEN CIRCLE MOVING (according to nX and nY coordinates)
void draw_green_circle_moving() {
  noStroke();
  fill(0, 255, 0);
  ellipse(nX, nY, diagonal, diagonal);
}

// DRAWS THE RED POINT MOVING (according to nX and nY coordinates)
void draw_red_point_moving() {
  noStroke();
  fill(255, 0, 0);
  ellipse(nX, nY, 10, 10);
}

// FUNCTION THAT CONNECT WITH RUNWAY
void connect() {
  OscMessage m = new OscMessage("/server/connect");
  oscP5.send(m, myBroadcastLocation);
}

// OSC Event: listens to data coming from Runway
void oscEvent(OscMessage theOscMessage) {
  if (!theOscMessage.addrPattern().equals("/data")) return;
  // The data is in a JSON string, so first we get the string value
  String dataString = theOscMessage.get(0).stringValue();
  // We then parse it as a JSONObject
  data = parseJSONObject(dataString);
  println(data);  
}
