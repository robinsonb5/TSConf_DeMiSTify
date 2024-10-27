#include <string.h>

#include "config.h"
#include "keyboard.h"
#include "diskimg.h"
#include "romimg.h"
#include "settings.h"
#include "statusword.h"

#include "c64keys.c"

#define TSCONF_CONFIG_VERSION 1

#define BLOB_HDD1 0

int LoadROM(const char *fn);

/* Config file starts with this structure, then the second 256 bytes is the Mac PRAM */
struct tsconf_config
{
	char version;
	char pad[3];
	int status;
	struct settings_blob blob[1];
};

struct tsconf_config configfile_data={
	TSCONF_CONFIG_VERSION,
	0x0,0x0,0x0,   /* Pad */
	0x00,          /* Status */
	{
		{              /* Default TSConf HD name */
			0x00, "TSCONF  HDF"
		},
	}
};


int loadimage(char *filename,int unit)
{
	int result=0;
	int u=unit-'0';

	switch(unit)
	{
		/* ROM images */
		case 0: /* ROM */
			result=LoadROM(filename);
			break;
		/* Hard disk images */
		case '0':
			settings_storeblob(&configfile_data.blob[unit-'0'],filename);
			diskimg_mount(0,unit-'0');				
			return(diskimg_mount(filename,unit-'0'));				
			break;
		case 'S':
			result=loadsettings(filename);
			break;
		case 'T':
			result=savesettings(filename);
			break;
	}
	sendstatus();
	return(result);
}


int configtocore(char *buf)
{
	struct tsconf_config *dat=(struct tsconf_config *)buf;
	int i;
	/* Load the config file to sector_buffer */

	if(dat->version==TSCONF_CONFIG_VERSION)
	{
		memcpy(&configfile_data,buf,sizeof(configfile_data)); /* Beware - at boot we're copying the default config over itself.  Safe on 832, but undefined behaviour. */
		statusword=configfile_data.status;

		if(dat!=&configfile_data)
			SendNVRAM(0x3f,buf+256,256);

		for(i=0;i<1;++i) {
			if(configfile_data.blob[i].filename[0])
				settings_loadblob(&configfile_data.blob[i],'0'+i);
		}
	}
	return(1);
}


void coretoconfig(char *buf)
{
	configfile_data.status=statusword;
	memset(buf,0,512);
	memcpy(buf,&configfile_data,sizeof(configfile_data));
	GetNVRAM(0x3f,buf+256,256);
}

int UpdateKeys(int blockkeys)
{
	handlec64keys();
	return(HandlePS2RawCodes(blockkeys));
}

__weak char *autoboot()
{
	char *result=0;
	romtype=0;
	if(!LoadROM("TSCONF  ROM"))
		result="ROM loading failed";
	romtype=1;
	/* Load soundcard ROM */
	if(!LoadROM("TSCONF  R01"))
		result="Sound ROM loading failed";
	/* Attempt to mount VHD */
	diskimg_mount("TSCONF  VHD",0);

	/* Load a config file, if present */
	loadimage("TSCONF  CFG",'S');

	initc64keys();
	
	return(result);
}

