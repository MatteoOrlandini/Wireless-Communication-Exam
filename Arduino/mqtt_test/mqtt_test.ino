/*
Copyright (c) 2019, SODAQ
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
*/

#include <Sodaq_R4X.h>

#define CONSOLE_STREAM   SerialUSB
#define MODEM_STREAM     Serial1

// Uncomment your operator
// #define MONOGOTO
// #define VODAFONE_LTEM
// #define VODAFONE_NBIOT
 #define CUSTOM

#if defined(MONOGOTO)
#define CURRENT_APN      "data.mono"
#define CURRENT_OPERATOR AUTOMATIC_OPERATOR
#define CURRENT_URAT     SODAQ_R4X_LTEM_URAT
#define CURRENT_MNO_PROFILE MNOProfiles::STANDARD_EUROPE
#elif defined(VODAFONE_LTEM)
#define CURRENT_APN      "live.vodafone.com"
#define CURRENT_OPERATOR AUTOMATIC_OPERATOR
#define CURRENT_URAT     SODAQ_R4X_LTEM_URAT
#define CURRENT_MNO_PROFILE MNOProfiles::VODAFONE
#elif defined(VODAFONE_NBIOT)
#define CURRENT_APN      "nb.inetd.gdsp"
#define CURRENT_OPERATOR AUTOMATIC_OPERATOR
#define CURRENT_URAT     SODAQ_R4X_NBIOT_URAT
#define CURRENT_MNO_PROFILE MNOProfiles::VODAFONE
#define NBIOT_BANDMASK "524288"
#elif defined(CUSTOM)
#define CURRENT_APN      "nbiot.tids.tim.it"
#define CURRENT_OPERATOR AUTOMATIC_OPERATOR
#define CURRENT_URAT     "8"
#define CURRENT_MNO_PROFILE MNOProfiles::SIM_ICCID
#else 
#error "Please define a operator"
#endif

#define MQTT_SERVER_NAME "broker.mqttdashboard.com"
#define MQTT_SERVER_PORT 8000

#ifndef NBIOT_BANDMASK
#define NBIOT_BANDMASK BAND_MASK_UNCHANGED
#endif

static Sodaq_R4X r4x;
static Sodaq_SARA_R4XX_OnOff saraR4xxOnOff;
static bool isReady;
static bool check;

void setup()
{
    while ((!CONSOLE_STREAM) && (millis() < 10000)){
        // Wait max 10 sec for the CONSOLE_STREAM to open
    }

    CONSOLE_STREAM.begin(115200);
    MODEM_STREAM.begin(r4x.getDefaultBaudrate());

    r4x.setDiag(CONSOLE_STREAM);
    r4x.init(&saraR4xxOnOff, MODEM_STREAM);

    isReady = r4x.connect(CURRENT_APN, CURRENT_URAT, CURRENT_MNO_PROFILE, CURRENT_OPERATOR, BAND_MASK_UNCHANGED, NBIOT_BANDMASK);

    CONSOLE_STREAM.println(isReady ? "Network connected" : "Network connection failed");

    if (isReady) {
        //check=r4x.mqttSetServer(MQTT_SERVER_NAME, MQTT_SERVER_PORT);
        //CONSOLE_STREAM.println(check ? "set ok" : "set failed");

        //check=r4x.mqttLogin();
        //CONSOLE_STREAM.println(check ? "login ok" : "login failed");
        
        isReady = r4x.mqttSetServer(MQTT_SERVER_NAME, MQTT_SERVER_PORT) && r4x.mqttLogin();
        CONSOLE_STREAM.println(isReady ? "MQTT connected" : "MQTT failed");      
    }

    if (isReady) {
        uint8_t buf0[] = {'t', 'e', 's', 't', '0'};
        uint8_t buf1[] = {'t', 'e', 's', 't', '1'};

        r4x.mqttPublish("/home/test/test0", buf0, sizeof(buf0));
        //r4x.mqttPublish("/home/test/test1", buf1, sizeof(buf1), 0, 0, 1);
        //r4x.mqttSubscribe("/home/test/#");
    }

    CONSOLE_STREAM.println("Setup done");
}

void loop()
{
    if (CONSOLE_STREAM.available()) {
        int i = CONSOLE_STREAM.read();
        CONSOLE_STREAM.write(i);
        MODEM_STREAM.write(i);
    }

    // if (MODEM_STREAM.available()) {
    //     CONSOLE_STREAM.write(MODEM_STREAM.read());
    // }

    if (isReady) {
        r4x.mqttLoop();

        if (r4x.mqttGetPendingMessages() > 0) {
            char buffer[2048];
            uint16_t i = r4x.mqttReadMessages(buffer, sizeof(buffer));

            CONSOLE_STREAM.print("Read messages:");
            CONSOLE_STREAM.println(i);
            CONSOLE_STREAM.println(buffer);
        }
    }
}
