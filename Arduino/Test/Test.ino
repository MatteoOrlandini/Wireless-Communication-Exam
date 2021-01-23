#include <Arduino.h>
#include <Sodaq_R4X.h>
#include <Sodaq_LSM303AGR.h>
#define R4XX // Uncomment when you use the ublox R4XX module

#if defined(ARDUINO_SODAQ_SARA) /* SODAQ SARA */
  #define DEBUG_STREAM SerialUSB
  #define MODEM_STREAM Serial1
  #define powerPin SARA_ENABLE
  #define enablePin SARA_TX_ENABLE
#else
  #error "Please select the SODAQ SARA as your board"
#endif
#if defined(R4XX)
  unsigned long baud = 115200; //start at 115200 allow the USB port to change the Baudrate
#else
  unsigned long baud = 9600; //start at 9600 allow the USB port to change the Baudrate
#endif

void setup()
{
#ifdef powerPin
  // Turn the nb-iot module on
  pinMode(powerPin, OUTPUT);
  digitalWrite(powerPin, HIGH);
#endif
#ifdef enablePin
  //Set state to active
  pinMode(enablePin, OUTPUT);
  digitalWrite(enablePin, HIGH);
#endif //enablePin

#if defined(R4XX)
  pinMode(SARA_R4XX_TOGGLE, OUTPUT);
  digitalWrite(SARA_R4XX_TOGGLE, LOW);
  delay(2000);
  pinMode(SARA_R4XX_TOGGLE, INPUT);
#endif
// Start communication
DEBUG_STREAM.begin(baud);
MODEM_STREAM.begin(baud);
}

// Forward every message to the other serial
void loop()
{
while (DEBUG_STREAM.available())
{
  MODEM_STREAM.write(DEBUG_STREAM.read());
  }
  while (MODEM_STREAM.available())
  {
    DEBUG_STREAM.write(MODEM_STREAM.read());
  }
  // check if the USB virtual serial wants a new baud rate
  // This will be used by the UEUpdater to flash new software
  if (DEBUG_STREAM.baud() != baud) {
    baud = DEBUG_STREAM.baud();
    MODEM_STREAM.begin(baud);
  }
}
