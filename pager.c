/*
 * Pager: Routines to create a "more" running out of a particular file
 * descriptor.
 *
 * Copyright 1987, 1988 by MIT Student Information Processing Board
 *
 * For copyright information, see copyright.h.
 */

#include "ss_internal.h"
#include "copyright.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/file.h>
#include <signal.h>

static char MORE[] = "more";
extern char *_ss_pager_name;
extern char *getenv();
extern int errno;

/*
 * this needs a *lot* of work....
 *
 * run in same process
 * handle SIGINT sensibly
 * allow finer control -- put-page-break-here
 */
void ss_page_stdin();

int ss_pager_create() 
{
	int filedes[2];
     
	if (pipe(filedes) != 0)
		return(-1);

	switch(fork()) {
	case -1:
		return(-1);
	case 0:
		/*
		 * Child; dup read half to 0, close all but 0, 1, and 2
		 */
		if (dup2(filedes[0], 0) == -1)
			exit(1);
		ss_page_stdin();
	default:
		/*
		 * Parent:  close "read" side of pipe, return
		 * "write" side.
		 */
		(void) close(filedes[0]);
		return(filedes[1]);
	}
}

void ss_page_stdin()
{
	int i;
	struct sigaction sa;
	sigset_t mask;
	
	for (i = 3; i < 32; i++)
		(void) close(i);
	sa.sa_handler = SIG_DFL;
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = 0;
	sigaction(SIGINT, &sa, (struct sigaction *)0);
	{
		sigemptyset(&mask);
		sigaddset(&mask, SIGINT);
		sigprocmask(SIG_UNBLOCK, &mask, (sigset_t *)0);
	}
	if (_ss_pager_name == (char *)NULL) {
		if ((_ss_pager_name = getenv("PAGER")) == (char *)NULL)
			_ss_pager_name = MORE;
	}
	(void) execlp(_ss_pager_name, _ss_pager_name, (char *) NULL);
	{
		/* minimal recovery if pager program isn't found */
		char buf[80];
		register int n;
		while ((n = read(0, buf, 80)) > 0)
			write(1, buf, n);
	}
	exit(errno);
}
