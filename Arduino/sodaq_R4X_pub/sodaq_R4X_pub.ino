/*!
 * \file sodaq_R4X_pub.ino
 *
 * Copyright (c) 2019 Gabriel Notman.  All rights reserved.
 *
 * This file is part of Sodaq_MQTT.
 *
 * Sodaq_MQTT is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 3 of
 * the License, or(at your option) any later version.
 *
 * Sodaq_MQTT is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with Sodaq_MQTT.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/*
 * This example shows how to do a MQTT PUBLISH via a GPRSbee connection.
 * It does the PUBLISH ten times and then it quits. The PUBLISH goes to
 * the test MQTT server at test.moquitto.org.
 *
 * To see the message you can subscribe, for example from the command
 * line with:
 *    mosquitto_sub -h test.mosquitto.org -t "SODAQ/demo/#"
 *
 * To build this example you need two Arduino libraries: Sodaq_MQTT and Sodaq_R4X.
 */


#include <Arduino.h>
#include <Sodaq_R4X.h>
#include <Sodaq_MQTT.h>
#include <Sodaq_R4X_MQTT.h>

#define MQTT_BROKER     "test.mosquitto.org"
#define MQTT_PORT       1883

#define APN             "nbiot.tids.tim.it"
#define URAT            "8"
#define MNOPROF         MNOProfiles::SIM_ICCID
#define OPERATOR        AUTOMATIC_OPERATOR
#define M1_BAND_MASK    BAND_MASK_UNCHANGED
#define NB1_BAND_MASK   BAND_MASK_UNCHANGED

static int counter = 0;

#if defined(ARDUINO_SODAQ_SARA) || defined(ARDUINO_SODAQ_SFF)
    #define MODEM_STREAM Serial1
    #define DEBUG_STREAM SerialUSB
#else
    #error "Please seletct SARA AFF or SFF"
#endif

Sodaq_R4X r4x;
Sodaq_SARA_R4XX_OnOff saraR4xxOnOff;
Sodaq_R4X_MQTT r4x_mqtt;

bool modemConnect()
{
    if (r4x.isConnected()) {
        return true;
    }
    else {
        DEBUG_STREAM.println("connecting");
        int flag=0;
        if (r4x.connect(APN, URAT)) {
          flag=1;
        }
        DEBUG_STREAM.println(flag? "connected" : "connection failed");
        return flag;
    }
}

void setup()
{
    while ((!SerialUSB) || (millis() < 5000)) {};

    // We'll use this to print some messages
    DEBUG_STREAM.begin(57600);
    DEBUG_STREAM.println("test_mqtt");

    // Set the MQTT server hostname, and the port number
    mqtt.setServer(MQTT_BROKER, MQTT_PORT);

    // OPTIONAL. Set the user name and password
    //mqtt.setAuth("Hugh", "myPass");

    // Set the MQTT client ID
    mqtt.setClientId("sodaq_pub_12345");

    // Set the MQTT keep alive
    mqtt.setKeepAlive(300);

    /*
     * The transport layer is a Sodaq_R4X
     */
    MODEM_STREAM.begin(r4x.getDefaultBaudrate());
    r4x.init(&saraR4xxOnOff, MODEM_STREAM);
    r4x.setDiag(DEBUG_STREAM);

    // Inform our mqtt instance that we use r4x as the transport
    r4x_mqtt.setR4Xinstance(&r4x, modemConnect);
    mqtt.setTransport(&r4x_mqtt);
}

void loop()
{
    const char * topic = "SODAQ/demo/test";
    String msg = "Our message, number " + String(counter);
    
    // PUBLISH something
    if (!mqtt.publish(topic, msg.c_str())) {
        DEBUG_STREAM.println("publish failed");
        while (true) {}
    }

    ++counter;
    if (counter >= 10) {
        mqtt.close();
        // End of the demo. Wait here for ever
	      while (true) {}
    }

    // Wait a little.
    delay(3000);
}
