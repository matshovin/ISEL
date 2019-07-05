
// Valg for kjøring
String gCodeInFileName = "../NC/0.nc";
String motorByteArrayFileName = "../1.stp";
float speedScale = 0.0003;              // typisk fra mm/min i F360 til mm/sec som er formatet i Processing CNC driver
boolean plott3D = false;
boolean plott3Di = true;
double stepFrequency = 1500.0;          // loop frequency in Arduino (Hz)

// Maskinparametre
double numbOfMicrostep = 4.0;                       // Can be set on motor driver (org8)                         
double stepSizeInMM = 4/(200.0*numbOfMicrostep);    // Screw pitch (mm/revolution) / 
// (motor step per revolution * numbOfMicrostep) (0.005) (org 2.5)
// Max possible linear speed = stepFrequency * stepSizeInMM - 7.5mm/sec
// Motor rotation speed = stepFrequency / (numbOfMicrostep * 200)

// Interne arrays
String[] gCodeArrayOnlyLinesOfG01;      // Ren G01 G code filtrert fra fil
double[][] lineArrayXYZT;               // [Line no][X Y Z endtime] (mm)(sec)
double[][] interpolPointArray;          // [Step no][X Y Z] (mm)
byte[] motorByteArray;                  // Motor control byte, 
// bit format: [notUsed notUsed dirZ stepZ dirY stepY dirX stepX]
int totalNoOfSteps;

//***********************************************************************

void setup()
{
  size(600, 500, P3D);
  cameraSetup();
  
  lesFil_FiltrerTil_gCodeArrayOnlyLinesOfG01(gCodeInFileName); 

  parse_gCodeArrayOnlyLinesOfG01_til_lineArrayXYZT();  

  parse_lineArrayXYZT_to_interpolPointArray();
  
  parse_interpolPointArray_to_motorByteArray();  

  printAll(0, 0.01); // debug
  print_gCodeArrayOnlyLinesOfG01(0, 3);
}

//***********************************************************************

void cameraSetup()
{
  background(11);
  frameRate(6);
  cameraX = cameraDist*cos(cameraAngHor)*cos(cameraAngVert) + cameraXcent; 
  cameraY = cameraDist*sin(cameraAngHor)*cos(cameraAngVert) + cameraYcent;    
  cameraZ = cameraDist*sin(cameraAngVert) + cameraZcent;   
}

void draw()
{
  // Lys
  lights();
  float dirY = (mouseY / float(height) - 0.5) * 2;
  float dirX = (mouseX / float(width) - 0.5) * 2;
  directionalLight(204, 204, 204, -dirX, -dirY, -1);
  spotLight(111, 111, 111, 111, 111, 111, -111, -111, -111, PI/2, 600); 
  lightSpecular(.2, .2, .8);
  background(11);  

  camera(cameraX, cameraY, cameraZ, cameraXcent, cameraYcent, cameraZcent, 0, 0, -1);
  perspective(PI/3.0, (float)width/height, 1, 100000);

  if (plott3D == true)
  {
    strokeWeight(1);
    stroke(255, 255, 255); 
    for (int i=0; i<lineArrayXYZT.length-1; i++) // lineArrayXYZT.length-2;
      line( (float)lineArrayXYZT[i][0], (float)lineArrayXYZT[i][1], (float)lineArrayXYZT[i][2], 
        (float)lineArrayXYZT[i+1][0], (float)lineArrayXYZT[i+1][1], (float)lineArrayXYZT[i+1][2] );
  }

  if (plott3Di == true)
  {
    strokeWeight(1);
    stroke(255, 255, 255); 
    for (int i=0; i<interpolPointArray.length-101; i=i+100) // lineArrayXYZT.length-2;
      line( (float)interpolPointArray[i][0], (float)interpolPointArray[i][1], (float)interpolPointArray[i][2], 
        (float)interpolPointArray[i+100][0], (float)interpolPointArray[i+100][1], (float)interpolPointArray[i+100][2] );
  }  

  strokeWeight(2);
  stroke(0, 0, 111);    
  line(0, 0, 0, 30, 0, 0); // blaa : x axe, pluss retn
  stroke(111, 0, 0);
  line(0, 0, 0, 0, 30, 0); // rod : y axe, pluss retn
  stroke(111, 111, 111);
  line(0, 0, 0, 0, 0, 30); // gul : z axe, pluss retn
}
