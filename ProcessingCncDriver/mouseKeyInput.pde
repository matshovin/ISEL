float cameraXcent = 0; // punkt som camera rettes mot
float cameraYcent = 0;
float cameraZcent = 0;

float cameraAngHor = 1;
float cameraAngVert = 1;
float cameraDist = 2*50; // funker bare i camera perspective

float cameraX; // camera i dette punkt
float cameraY;
float cameraZ;

void mouseDragged() 
{
  if (mouseButton==LEFT)
  {
    cameraAngHor = cameraAngHor + (mouseX-pmouseX)*0.01;
    cameraAngVert = cameraAngVert + (mouseY-pmouseY)*0.01;

    if (cameraAngVert>(PI/2.0-0.1))
      cameraAngVert = (PI/2.0-0.1);

    if (cameraAngVert<-(PI/2.0-0.1))
      cameraAngVert = -(PI/2.0-0.1);
  }

  cameraX = cameraDist*cos(cameraAngHor)*cos(cameraAngVert) + cameraXcent; 
  cameraY = cameraDist*sin(cameraAngHor)*cos(cameraAngVert) + cameraYcent;    
  cameraZ = cameraDist*sin(cameraAngVert) + cameraZcent;
}

void mouseWheel(MouseEvent event) 
{
  float e = event.getCount();

  if (e>0)
    cameraDist = cameraDist*1.04;
  else
    cameraDist = cameraDist*0.96; 

  cameraX = cameraDist*cos(cameraAngHor)*cos(cameraAngVert) + cameraXcent; 
  cameraY = cameraDist*sin(cameraAngHor)*cos(cameraAngVert) + cameraYcent;    
  cameraZ = cameraDist*sin(cameraAngVert) + cameraZcent;
}
