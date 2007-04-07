// You'll need OSCPack to compile this:
// http://www.audiomulch.com/~rossb/code/oscpack/
// Please set the OSCPACK_HOME directory to the directory where you installed oscpack.. 
// I have included a static LIB for oscpack in the lib dir, 
// so if you are compiling with VC .NET then you don't need to compile oscpack.. 

#ifdef WIN32
#pragma once
#define WIN32_LEAN_AND_MEAN 
#define _WIN32_WINNT  0x0500
#endif

#include <map>
#include <cv.h>
#include <highgui.h>

#include "TouchScreenDevice.h"
#include "TouchData.h"

using namespace touchlib;

#include <stdio.h>
#include <string>


ITouchScreen *screen;

#include "osc/OscOutboundPacketStream.h"
#include "ip/UdpSocket.h"


#define ADDRESS "127.0.0.1"
#define PORT 3333

#define OUTPUT_BUFFER_SIZE 2048



///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////

// FIXME: allow address and port to be specified on the command line or from a config file.. 

class OSCApp : public ITouchListener
{
public:


	OSCApp()
	{
		transmitSocket = new UdpTransmitSocket( IpEndpointName( ADDRESS, PORT ) );
	    


		frameSeq = 0;

	}

	~OSCApp()
	{
		delete transmitSocket;
	}



	//! Notify that a finger has just been made active. 
	virtual void fingerDown(TouchData data)
	{
		RgbPixel c;
		c.r = 255;
		c.g = 255;
		c.b = 255;

		fingerList[data.ID] = data;

		
		printf("Press detected: %f, %f\n", data.X, data.Y);

	}

	//! Notify that a finger has moved 
	virtual void fingerUpdate(TouchData data)
	{

		fingerList[data.ID] = data;


	}

	//! A finger is no longer active..
	virtual void fingerUp(TouchData data)
	{
		std::map<int, TouchData>::iterator iter;


		for(iter=fingerList.begin(); iter != fingerList.end(); iter++)
		{
			if(iter->second.ID == data.ID)
			{
				fingerList.erase(iter);

				return;
			}
		}
	}

	void frame()
	{
		// send update messages..

		char buffer[OUTPUT_BUFFER_SIZE];
		osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
		std::map<int, TouchData>::iterator iter1, iter2, iter_last;	    

		if(fingerList.size() > 0)
		{	    
			//p << osc::BeginBundleImmediate;


			int scount = 0, acount = 0;
			iter1=fingerList.begin();
			
			bool done=false;

			while(!done)
			{
				p.Clear();
				p << osc::BeginBundle();

				for(; iter1 != fingerList.end(); iter1++)
				{
					TouchData d = (*iter1).second;
					float m = sqrtf((d.dX*d.dX) + (d.dY*d.dY));
					if(!(d.X == 0 && d.Y == 0)) {
						p << osc::BeginMessage( "/tuio/2Dcur" ) << "set" << d.ID << d.X << d.Y << d.dX << d.dY << m << d.Area << osc::EndMessage;

						scount ++;
						if(scount >= 10)
						{
							scount = 0;
							break;
						}
					}
				}

				if(iter1 == fingerList.end())
					done = true;


				p << osc::BeginMessage( "/tuio/2Dcur" );
				p << "alive";
				for(iter2=fingerList.begin(); iter2 != fingerList.end(); iter2++)
				{
					TouchData d = (*iter2).second;
					if(!(d.X == 0 && d.Y == 0)) {
						p << d.ID;
					}
				}
				p << osc::EndMessage;

				p << osc::BeginMessage( "/tuio/2Dcur" ) << "fseq" << frameSeq << osc::EndMessage;
				p << osc::EndBundle;

				//printf("%d size. %d #fingers\n", p.Size(), fingerList.size());
				frameSeq ++; 
				if(p.IsReady())
					transmitSocket->Send( p.Data(), p.Size() );
			}


		} else {
			//p << osc::BeginBundleImmediate;
			p.Clear();
			p << osc::BeginBundle();

			p << osc::BeginMessage( "/tuio/2Dcur" );
			p << "alive";
			p << osc::EndMessage;

			p << osc::BeginMessage( "/tuio/2Dcur" ) << "fseq" << frameSeq << osc::EndMessage;

			p << osc::EndBundle;

			frameSeq ++;
			//printf("%d size\n", p.Size());

			if(p.IsReady())
				transmitSocket->Send( p.Data(), p.Size() );


		}

	}

private:
	UdpTransmitSocket *transmitSocket;

	// Keep track of all finger presses.
	std::map<int, TouchData> fingerList;
	int frameSeq;


};

/////////////////////////////////////////////////////////////////////////

OSCApp app;
bool ok=true;


int main(int argc, char * argv[])
{
	screen = TouchScreenDevice::getTouchScreen();
	//screen->setDebugMode(false);
	if(!screen->loadConfig("config.xml"))
	{
		screen->pushFilter("dsvlcapture", "capture1");
		screen->pushFilter("mono", "mono2");
		screen->pushFilter("smooth", "smooth3");
		screen->pushFilter("backgroundremove", "background4");

		screen->pushFilter("brightnesscontrast", "bc5");
		screen->pushFilter("rectify", "rectify6");

		screen->setParameter("rectify6", "level", "25");

		screen->setParameter("capture1", "source", "cam");
		screen->setParameter("bc5", "brightness", "0.1");
		screen->setParameter("bc5", "contrast", "0.4");

		screen->saveConfig("config.xml");
	}

	screen->registerListener((ITouchListener *)&app);
	// Note: Begin processing should only be called after the screen is set up

	screen->beginProcessing();
	screen->beginTracking();

	do
	{

		int keypressed = cvWaitKey(32) & 255;

		if(keypressed != 255 && keypressed > 0)
			printf("KP: %d\n", keypressed);
        if( keypressed == 27) break;		// ESC = quit
        if( keypressed == 98)				// b = recapture background
		{
			screen->setParameter("background4", "capture", "");
		}
        if( keypressed == 114)				// r = auto rectify..
		{
			screen->setParameter("rectify6", "level", "auto");
		}

		screen->getEvents();

		app.frame();

	} while( ok );


	TouchScreenDevice::destroy();
	return 0;
}