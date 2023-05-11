void setup() {
Serial.begin(115200);
pinMode(35,INPUT);
}
void loop() {
Serial.println(analogRead(35));
delay(100);
}
