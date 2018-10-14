import controlP5.*;

import processing.serial.*;
import themidibus.*;
import java.util.*;

ControlP5 cp5;
MidiBus myBus; // The MidiBus
Serial myPort;

int lf = 10; 
color bg = color(5,28,59);
color col2 = color(30,61,90);
color col1 = color(128,164,190);
color col3 = color(229,239,238);

int barHeight = 40;
String midiName = "BALLERN";
String serialSelected;

String[] serialPorts;

int serialCounter = 0;

int channel = 0;


int buttonWidth = 200;
int buttonHeight = 50;

int buttonYdelta = 100;

Textfield portNameField;
Textfield midiNameField;

boolean serialConnected = false;

int lastNote = 0;
long lastNoteOff;
int noteOffFreq = 500;

void setup() {
  cp5 = new ControlP5(this)
  .setColorForeground(col1)
  .setColorForeground(col2)
  .setColorActive(col3); 
  myBus = new MidiBus(this, -1, midiName);
  println(myBus);
  serialPorts = Serial.list();

  serialSelected = serialPorts[0];

  portNameField = cp5.addTextfield("portName")
    .setSize(buttonWidth, buttonHeight)
    .setPosition((width-buttonWidth)/2, 100 + 0 * buttonYdelta)
    .setText("   " +serialSelected)
    ;

  cp5.addBang("nextSerial")
    .setSize(buttonWidth/2-10, buttonHeight)
    .setPosition(width/2 + 10, 100 + 1 * buttonYdelta)
    .setLabel("next");

  cp5.addBang("lastSerial")
    .setSize(buttonWidth/2-10, buttonHeight)
    .setPosition((width-buttonWidth)/2, 100 + 1 * buttonYdelta)
    .setLabel("last");

  cp5.addBang("connect")
    .setSize(buttonWidth, buttonHeight)
    .setPosition((width-buttonWidth)/2, 100 + 2 * buttonYdelta)
    .setLabel("connect");
    
    
  cp5.addBang("exitRoutine")
    .setSize(buttonWidth, buttonHeight)
    .setPosition((width-buttonWidth)/2, 100 + 3 * buttonYdelta)
    .setLabel("exit");

  size(500, 600);
  globalOff();
}

void draw() {
  background(bg);
  if(millis() > lastNoteOff){
    myBus.sendNoteOff(channel, lastNote, 0);
    lastNoteOff+=noteOffFreq;
  }
  String myString = "";
  if (serialConnected) {

    while (myPort.available() > 0) {
      myString = myPort.readStringUntil(lf);
      if (myString != null) {
        println("----------");
        String cmd[] = split(myString.trim(),',');
        println(cmd[0]);
        println(cmd[1]);
        myBus.sendNoteOff(channel, lastNote, 0);
        myBus.sendNoteOn(channel, int(cmd[0]),int(cmd[1]));
        lastNote = int(cmd[0]);
        lastNoteOff = millis() + noteOffFreq;
        printArray(cmd);
      }
    }
  }
}

void dropdown(int n) {
  println(n, cp5.get(ScrollableList.class, "dropdown").getItem(n));
  CColor c = new CColor();
  c.setBackground(color(255, 0, 0));
  String test = cp5.get(ScrollableList.class, "dropdown").getStringValue();
  println(test);
}

void nextSerial() {
  println("next");

  serialCounter++;
  if (serialCounter == serialPorts.length) {
    serialCounter = 0;
  }
  serialSelected = serialPorts[serialCounter];
  portNameField.setText("   " + serialSelected);
  println("last");
}

void lastSerial() {
  serialCounter --;
  if (serialCounter < 0) {
    serialCounter = serialPorts.length-1;
  }
  serialSelected = serialPorts[serialCounter];
  portNameField.setText("   " + serialSelected);
  println("last");
}

void connect() {
  myPort  = new Serial(this, serialSelected, 9600);
  serialConnected = true;
  while(myPort.available() > 0){
    myPort.read();
  }
}

void exitRoutine(){
  globalOff();
  if(serialConnected)myPort.stop();
  myBus.close();
  delay(100);
  exit();
}

void globalOff(){
  for(int i = 0; i < 127; i++){
    myBus.sendNoteOff(channel, i, 0);
  }
}
