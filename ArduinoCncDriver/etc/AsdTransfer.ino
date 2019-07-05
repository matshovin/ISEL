// Overfører direkte "1.stp" fra PC til Arduino SD
#include <SPI.h>
#include <SD.h>

File myFile;

void setup()
{
  Serial.begin(19200);
  SD.begin(8);

  SD.remove("1.stp"); 
  
  File dataFile = SD.open("1.stp", FILE_WRITE);

  if ( !dataFile )
    Serial.write(60);  

  long int i;
  i = 0;
  boolean slutt = false;

  while ( !slutt )
  {
    if (Serial.available() > 0)
    {
      byte b = Serial.read();
      if ( b == 255)
        slutt = true;
      else
      {
        dataFile.write(b);
        Serial.write(b);
      }
      i++;
    }
  }
  dataFile.close();
  Serial.write(66);
}



void loop()
{


}
