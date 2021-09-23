// Dit is het bestand voor alex om de parkeer sensor toetevoegen

void PakeerSetup() {
  const int trigPin = 2;  // TRIG aan pin 2
const int echoPin = 4;  // ECHO aan pin 4
const int led = 13;     // LED aan pin 13
const int BuzzerPin = 11;
long duration;          // variabele voor de tijdslengte



  pinMode(trigPin, OUTPUT); // TRIG is output
  pinMode(echoPin, INPUT);  // ECHO is input
}

void PakeerLoopSchool() {
  digitalWrite(trigPin, LOW);         // LOW op TRIG geeft geen ultrasoon signaal
  delayMicroseconds(2);               // wacht 2 mircoseconden
  digitalWrite(trigPin, HIGH);        // begin het ultrasoon signaal
  delayMicroseconds(10);              // wacht 10 microseconden
  digitalWrite(trigPin, LOW);         // stop het ultrasoon signaal
  duration = pulseIn(echoPin, HIGH);  // lees het signaal wat terugkomt in vertraging
  
  /*
    op de echoPin, de tijd die tussen uitzenden en ontvangen zit is
    maatgevend voor de afstand, de tijd is in microseconden
  */
  
  if (duration < 1000) {        // als de echotijd kleiner is dan 100 dan...
    // Check rssi
    int BiggestRssi = 0;
    Device d;
    for (int i = 0; i < count; i++) {
       if (BiggestRssi > devices[i].rssi) {
           BiggestRssi = devices[i].rssi;
           d = devices[i];
        }
    } 
    if (d.rssi < -100) {
      
    }
  }
}

void PakeerLoopThuis() {
    long distance;
    pinMode(3, OUTPUT);
    digitalWrite(3, LOW);
    delayMicroseconds(2);
    digitalWrite(3, HIGH);
    delayMicroseconds(10);
    digitalWrite(3, LOW);
    pinMode(3, INPUT);
    distance = pulseIn(3, HIGH);
   
    if((((double)distance / 58.0) >= 400.0) || (distance == 0)) {
        Serial.println((double) 400.0); // MAX afstand cm
    }
  
    if ((distance / 58.0) > 20) { // Als de afstand kleiner is dan 20 cm (TODO: naar 2 meter ofzo maken) dan loopt er iemand langs
       Serial.println( (double)distance / 58.0);
    // Check rssi ook hoog is van een device in de buurt
    int BiggestRssi = 0;
    for (int i = 0; i < count; i++) {
       if (BiggestRssi > devices[i].rssi) {
           BiggestRssi = devices[i].rssi;
        }
    } 
    if (BiggestRssi < -100) {
      // Check of het meer of minder word
    }
  }
}
