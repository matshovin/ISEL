// Arduino Duecemillanove 
// PORT D Arduino pinner: [7 6 5 4 3 2 TX RX] (driver)
// PORT C Arduino pinner: [? Reset A5 A4 A3 A2 A1 A0] (pos brytere)
// PORT B Arduino pinner: [? ? 13 12 11 10 9 8] (start stop bryter)
// MD28 driver timing req: 5us dir edge til step edge, 1.6us step høy/lav lengde

#include <SPI.h>
#include <SD.h>

File myFile;
boolean isRunning = false;

long int stepBaudRate = 3000;
int stepPeriode = (long int)1000000/stepBaudRate - 8; // 8um delay mellom dir og pulse



void setup()
{
  // PORT D
  pinMode(2, OUTPUT); // X step/pulse
  digitalWrite(2, LOW);
  pinMode(3, OUTPUT); // X dir
  digitalWrite(3, LOW); // X-
  
  pinMode(4, OUTPUT); // Y step/pulse
  digitalWrite(4, LOW);
  pinMode(5, OUTPUT); // Y dir
  digitalWrite(5, LOW); // Y+
  
  pinMode(6, OUTPUT); // Z step/pulse
  digitalWrite(6, LOW);
  pinMode(7, OUTPUT); // Z dir
  digitalWrite(7, LOW); // Z+

  // PORT C
  // Brytere kjøres rett ut på pinne 2-7 når de aktiveres lav, alle leses samtidig i en byte, PORT D
  pinMode(A0, INPUT_PULLUP);
  pinMode(A1, INPUT_PULLUP);
  pinMode(A2, INPUT_PULLUP);
  pinMode(A3, INPUT_PULLUP);
  pinMode(A4, INPUT_PULLUP);
  pinMode(A5, INPUT_PULLUP);

  // PORT B 
  pinMode(9, INPUT_PULLUP); // Start jobb
  pinMode(10, INPUT_PULLUP); // Stopp jobb

  Serial.begin(9600); // info til PC
}


void loop()
{
  if ( isRunning )
  {
    if (myFile.available())
    {
      byte s = myFile.read();

      s = s<<2; // unngår å skrive over pin RX/TX
      s = 0b10100000^s; // retningsjustering, bitswapper Ydir og Zdir
      // Dir ut
      PORTD = (s & 0b10101000) | (PORTD & 0b01010111); // overfører og beholder opprinelige Rx,Tx, XYZ step verdier
      delayMicroseconds(8); // EasyDriver timing reqirements er 5us
      // Step ut
      PORTD = (s & 0b01010100) | (PORTD & 0b10101011); // overfører og beholder opprinelige Rx,Tx, XYZ dir verdier
    }
    else // if not new SD byte available 
    {
      isRunning = false;
      myFile.close();
      Serial.println("NC run finish");
    }
  }
  else // not running
  {
    // Leser brytere på A0-A5
    byte analogIN = ~PINC; // omformer fra active low to active high

    // Kjører ut A0-A5 på XYZ dir og step pinner hvis trykket
    if ( analogIN )
    {
      // skifter vekk rare bits som ikke skal brukes
      byte stepDirUt = analogIN << 2;

      stepDirUt = 0b10100000^stepDirUt; // retningsjustering, bitswapper Ydir og Zdir
      // Dir ut 
      PORTD = (stepDirUt & 0b10101000) | (PORTD & 0b01010111); // overfører og beholder opprinelige Rx,Tx, XYZ step verdier
      delayMicroseconds(8); // EasyDriver timing reqirements er 5us
      // Step ut
      PORTD = (stepDirUt & 0b01010100) | (PORTD & 0b10101011); // overfører og beholder opprinelige Rx,Tx, XYZ dir verdier
    }
  }

  // Leser alltid start / stop brytere
  byte swStartStop = ~PINB;  // omformer fra active low to active high
  if ( swStartStop & 0b00000100 ) // Stop CNC run (pin11)
    isRunning = false;
  else if ( swStartStop & 0b00000010 ) // start CNC run (pin10)
    if (isRunning == false)  // initier SD
    {
      if (SD.begin(8))
        Serial.println("NC run start");
      delay(2000);
      myFile = SD.open("1.stp");
      if (myFile)
        Serial.println("1.stp opened");
      isRunning = true;
    }
  
  delayMicroseconds(stepPeriode);
  PORTD = B10101011 & PORTD;  // nuller ut xyz step pins for å pulse ned
}
