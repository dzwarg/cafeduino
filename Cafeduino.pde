#include <Print.h>
#include <Ethernet.h>
#include <Client.h>
#include <Server.h>
#include <string.h>
#include <stdio.h>

/* pin assignments */
int led1 = 6; // led 1
int led2 = 9; // led 2
int led3 = 10; // led 3
int piezo1 = 5; //piezo 1
int piezo2 = 4; //piezo 2
int button1 = 2; //tare switch
int button2 = 3; //full switch

int v1 = 0; //measured value 1
int v2 = 0; //measured value 2
int tareVal = 0;  // tare empty value
int maxVal = 1023;  // tare max value

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xBA, 0xBE }; // MAC is 0xDEAFBEEFBABE
byte ip[] = { 192, 168, 1, 96 };                         // IP is 10.0.0.9
byte gateway[] = { 192, 168, 1, 1 };                    // Gateway is 10.0.0.1
byte subnet[] = { 255, 255, 255, 0 };                    // Subnet is 255.0.0.0
byte remote[] = { 209,40,205,190 };                  // pachube.com

Client pachube( remote, 80 );
Server localhost( 80 );

unsigned long flash_interval = 1000;
unsigned long interval = 60000;  // 1 min
unsigned long update_time = millis();

char pachube_data[50];
char request_data[50];
int totalread = 0;

void setup()
{
  Serial.begin(9600);

  pinMode( led1, OUTPUT );
  pinMode( led2, OUTPUT );
  pinMode( led3, OUTPUT );
  
  pinMode( button1, INPUT );
  pinMode( button2, INPUT );
  
  Ethernet.begin( mac, ip, gateway, subnet );
  delay(500);
  localhost.begin();
}

void loop()
{
  v1 = analogRead( piezo1 );
  v2 = analogRead( piezo2 );

  if( digitalRead( button1 ) == HIGH )
    tareVal = v1 + v2;

  if ( digitalRead( button2 ) == HIGH )
    maxVal = v1 + v2;

  sprintf(pachube_data,"%d,%d,%d,%d,%ld",tareVal,v1,v2,maxVal,millis());
  int content_length = strlen(pachube_data);

  // only publish once per interval
  if ( millis() > update_time + interval )
  {
    update_time = millis();

    if ( pachube.connect() ) {  
      pachube.println("PUT /api/2582.csv HTTP/1.1");
      pachube.println("Host: pachube.com");
      //pachube.println("X-PachubeApiKey: key");
      pachube.println("User-Agent: Arduino (Custom)");
      pachube.println("Content-Type: text/csv");
      pachube.print("Content-Length: ");
      pachube.println(content_length);
      pachube.println("Connection: close\n");
      pachube.println(pachube_data);

      pachube.stop(); 
    }
  }

  // try to connect to a web client, if anyone is out there
  Client web = localhost.available();
  if (web) {
    int toread = web.available();
    int beenread = 0;

    while ( beenread < toread && beenread < 50 ) {
      request_data[beenread] = web.read();
      beenread++;

      if ( request_data[beenread-1] == '\n' ) {
        request_data[beenread-1] == '\0';
        break;
      }      
    }

    char rstr[3];
    memset( rstr, '\0', 3 );

    char req = sscanf( request_data, "GET %2c", rstr);

    if ( req != EOF && strcmp( rstr, "/ " ) == 0 ) {

      web.write( "HTTP/1.0 200 OK\n" );
      web.write( "Connection: close\n" );
      web.write( "Content-Length: " );
      web.println( content_length );
      web.write( "Content-Type: text/plain\n\n" );
      web.println( pachube_data );
    }
    else {
      web.write( "HTTP/1.0 404 Not Found\n" );
      web.write( "Content-Type: text/plain\n\n" );
      web.write( "URL not found." );
    }

    web.flush();
    web.stop();
  }

  // send data only when you receive data:
  if (Serial.available() > 0) {
    // read the incoming byte:
    if( Serial.read() == 'r' ) {
      // say what you got:
      Serial.println(pachube_data);
    }
  }
  
  int warn = LOW;
  if ( (v1 + v2) < tareVal ) {
    if ( millis() % (2 * flash_interval) < flash_interval )
      warn = HIGH;
  }

  analogWrite( led1, constrain(map(v1,tareVal,maxVal,0,255),0,255) );
  analogWrite( led2, constrain(map(v2,tareVal,maxVal,0,255),0,255) );
  digitalWrite( led3, warn );
}

