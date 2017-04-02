#include "stdlib.h"
#include <stdio.h> 
#include <string.h>

#undef TESTWIN

#ifdef TESTWIN
#define _MSC_VER
#endif

#ifdef _MSC_VER
static const int isvs = 1;
#else
static const int isvs = 0;
#endif

static char* drive = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

static int
tolowercase(int c)
{
    if(c >= 'A' && c <= 'Z') {
	c = (c - 'A') + 'a';
    }
    return c;
}

int
main(int argc, char** argv)
{
    int i;
    const char* inpath = NULL;
    char outpath[8192];
    int iswin = 0;

    if(argc < 2) {
	fprintf(stderr,"pathcvt: too few arguments\n");
	exit(1);
    }

    inpath = argv[1];

    /* Quick discriminant */
    if(strlen(inpath) < 2)
	iswin = 0;
    else if(strchr(drive,inpath[0]) != NULL && inpath[1] == ':')
	iswin = 1;
    else
	iswin = 0;

    /* 4 cases isvs X iswin */
    if(isvs && iswin)
	goto pass; /* nothing to do */

    if(!isvs && !iswin)
	goto pass; /* nothing to do */

    if(isvs && !iswin) { /* Convert cygwin to windows */
        size_t cdlen = strlen("/cygdrive/");
        int letter;
        int slash;
        if(strlen(inpath) < cdlen+1)
	    goto pass; /* not cygwin */
        letter = inpath[cdlen];
        slash = inpath[cdlen+1];
        if(memcmp(inpath,"/cygdrive/",cdlen)==0
	   && strchr(drive,letter) != NULL
           && (slash == '/' || slash == '\0')) { /* cygwin path */
	    outpath[0] = (char)letter;
	    outpath[1] = ':';
	    strcpy(&outpath[2],&inpath[cdlen+1]);
	    goto done;
	} else
	    goto pass; /* not cygwin */
    }

    if(!isvs && iswin) { /* Convert windows to cygwin */
        char lc[2];
	lc[0] = (char)tolowercase(inpath[0]);
	lc[1] = '\0';
	strcpy(outpath,"/cygdrive/");
	strcat(outpath,lc);
	strcat(outpath,&inpath[2]);
	goto done;
    }

pass:
    strcpy(outpath,inpath);

done:
    printf("%s\n",outpath);
    fflush(stdout);
    exit(0);
}
