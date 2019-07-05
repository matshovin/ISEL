// ISEL FLATCOM FB2 .... mega 2560
// enkel test med riktige verdier på retninger

int T = 500;  // uSec 

void setup() 
{
  pinMode(2, OUTPUT);   // DIR X - GREY
  digitalWrite(2, LOW); // X+
  pinMode(3, OUTPUT);   // PULS X - BLUE
  digitalWrite(3, HIGH); 

  pinMode(4, OUTPUT);   // DIR Y - GREY
  digitalWrite(4, LOW); // Y-
  pinMode(5, OUTPUT);   // PULS Y - BLUE  
  digitalWrite(5, LOW);

  pinMode(6, OUTPUT);   // DIR Z - GREY
  digitalWrite(6, LOW); // Z-
  pinMode(7, OUTPUT);   // PULS Z - BLUE  
  digitalWrite(7, LOW);  

  pinMode(8, INPUT_PULLUP); // START
  pinMode(9, INPUT_PULLUP); // STOP    
}

void loop()
{
  int s = digitalRead(8); 
  
  if (s == LOW)
  {
    digitalWrite(5,HIGH); 
    delayMicroseconds(T);
    digitalWrite(5,LOW); 
  }

}
