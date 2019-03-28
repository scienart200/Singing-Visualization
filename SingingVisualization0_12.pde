//Import  sound library
import processing.sound.*;
SoundFile SoundRef;
Amplitude rms;

/******************Setting Section*************************/
/*PLEASE SETUP THE PARAMETERS ACCORDING TO PUREDATA AND NEEDS*/
float loudmin=30,loudmax=86;//look for pure data to calibrate

float loudmin_ref=30, loudmax_ref=86;
float pitchmin=40,pitchmax=70;//set vocal range of the singer   for female;
float pitchrange=pitchmax-pitchmin;
//smoothingFactor is used to avoid abrupt changes, 0 is SMOOTH but LESS SENSITIVE, 1 is AGILE but JUMPY
float smoothingFactor = 0.1;//suggestion: FAST music set to 0.2; SLOW music set to 0.02-0.1
//beat related variables
String TimeSig="4/4";
int bpm=100;
//
/********End of setting section*****************************/


//Import osc-related library
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myAddress;//same with oscformat
float pitch, pitch_ref;
float loudness, loudness_ref;
// Used for storing the smoothed amplitude value
float sumloudness,loudness_scale;
float sumloudness_ref,loudness_scale_ref;
float sumpitch,pitch_scale;
float sumpitch_ref,pitch_scale_ref;


//MIDI Note No. =69+log2(f/440);

/*SETUP*/
void setup(){
  
  size(1200,900);
  
  
  
  // start oscP5, listening for incoming messages at port 5000--check to be same with pd localhost 
  oscP5 = new OscP5(this,5000);//in accordance with "connect localhost No."
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. */
  myAddress = new NetAddress("127.0.0.1",5000);//if it's on the same computer, always use this one

  /*//load & play a soundfile and loop it
  SoundRef=new SoundFile(this,"SilentNight_Soprano.wav");
  SoundRef.loop();
  
  //Loudness tracker
  rms= new Amplitude(this);
  rms.input(SoundRef);*/
   
}


void draw() {
  
  //background color
  colorMode(RGB,255,255,255);
  background(240);
  fill(220);
  rect(0,0,width/2,height);
  
  
  // clock on screen;
  //int ms=millis()%1000;
  int sec=int(millis()/1000);
  int min=int(millis()/6000);
  String clock=min+":"+sec;//+":"+ms;
  noStroke();
  fill(#135FA0);
  text(clock,10,10);

  DrawSoundRef();
  DrawSinging();
  
}


/*This function draws soundreference*/
void DrawSoundRef(){
   //////STEP NEXT1: COLOR CONTROL
  noStroke();
  //fill(51,129,200,150); //darker blue
  colorMode(HSB,360,255,255);

  //smooth color
   sumpitch_ref+=(pitch_ref-sumpitch_ref)*smoothingFactor;
  pitch_scale_ref=sumpitch_ref*165/pitchrange-165/pitchrange*pitchmin+90;//MIDI No.: C2-36 C3-48  C4-60 C6(known as high C)-84  //map pitchrange to 0-255
  fill(220,204,pitch_scale_ref,160);//change saturation
 // fill(210,(100-sumpitch)*0.8,150,180);//change brightness
  println(pitch_scale_ref,sumpitch_ref);
  
  //STEP NEXT2:SIZE CONTROL
  //sum_rtloudness+=(loudness-sum_rtloudness)/60*smoothingFactor; //smooth loudness
  if(loudness_ref>=loudmin_ref){  //only when 
   sumloudness_ref+=(loudness_ref-sumloudness_ref)*smoothingFactor;
  loudness_scale_ref=sumloudness_ref*width/4/(loudmax_ref-loudmin_ref)+loudmin_ref*width/4/(loudmin_ref-loudmax_ref);
  
  ellipseMode(RADIUS);
  ellipse(width*1/4, height/2,loudness_scale_ref,loudness_scale_ref);
  
  //println("loudness:",loudness," LoudRef:",LoudRef);
  //print( loudness_scale);
  }
   else{
       ellipseMode(RADIUS);
        ellipse(width*1/4, height/2,10,10);
   }
  
}


/*This function draws singing data sent from Puradata*/
void DrawSinging(){
  
  //////STEP NEXT1: COLOR CONTROL
  noStroke();
  //fill(51,129,200,150); //darker blue
  colorMode(HSB,360,255,255);

  //smooth color
   sumpitch+=(pitch-sumpitch)*smoothingFactor;
  pitch_scale=sumpitch*165/pitchrange-165/pitchrange*pitchmin+90;//MIDI No.: C2-36 C3-48  C4-60 C6(known as high C)-84  //map pitchrange to 0-255
  fill(220,204,pitch_scale,160);//change saturation
 // fill(210,(100-sumpitch)*0.8,150,180);//change brightness
  println(pitch_scale,sumpitch);
  
  //STEP NEXT2:SIZE CONTROL
  //sum_rtloudness+=(loudness-sum_rtloudness)/60*smoothingFactor; //smooth loudness
  if(loudness>=loudmin){  //only when 
   sumloudness+=(loudness-sumloudness)*smoothingFactor;
  loudness_scale=sumloudness*width/4/(loudmax-loudmin)+loudmin*width/4/(loudmin-loudmax);
  
  ellipseMode(RADIUS);
  ellipse(width*3/4, height/2,loudness_scale,loudness_scale);
  
  //println("loudness:",loudness," LoudRef:",LoudRef);
  //print( loudness_scale);
  }
   else{
       ellipseMode(RADIUS);
        ellipse(width*3/4, height/2,10,10);
   }

}

/* parsing oscMessage. */
void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  if(theOscMessage.checkAddrPattern("/myAddress")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("ffff")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      float RawpitchValue = theOscMessage.get(0).floatValue();//get(0) means the first message  
      loudness = theOscMessage.get(1).floatValue();//get(1)means the second message
      float RawpitchValue_ref = theOscMessage.get(2).floatValue();
      loudness_ref = theOscMessage.get(3).floatValue();
      //check silence of singing voice
      if(RawpitchValue==-1500){
        pitch=pitchmin;//lowest pitch one can sing
      }
      else{
        pitch=RawpitchValue;
        }
        
       //check silence of reference audio 
       if(RawpitchValue_ref==-1500){
        pitch_ref=pitchmin;//lowest pitch one can sing
      }
      else{
        pitch_ref=RawpitchValue_ref;
        }

     //println(loudness);
      return;
    }  
  } 
}