#
#	Makefile for ss library
#
# Copyright 1987, 1988 by the MIT Student Information Processing Board
# For copyright info, see copyright.h.
#
#	$Header: /afs/dev.mit.edu/source/repository/athena/lib/ss/Makefile,v 1.7 1990-02-09 09:57:51 epeisach Exp $
#	$Locker:  $

MACHINE=`/bin/athena/machtype`
DESTDIR=
BINDIR=
LIBDIR=
INCDIR=
#ETDIR=../../et/src/

# flags

CFLAGS=	-O -I. -g

LINTFLAGS= -uhv

# for the library

LIB=	libss.a
COMERR=	-lcom_err
#COMERR=	$(ETDIR)libcom_err.a

# with ss_err.o first, ss_err.h should get rebuilt first too.  shouldn't
# be relying on this, though.
OBJS=	ss_err.o \
	std_rqs.o \
	invocation.o help.o \
	execute_cmd.o listen.o parse.o error.o prompt.o \
	request_tbl.o list_rqs.o pager.o requests.o \
	data.o

SRCS=	invocation.c help.c \
	execute_cmd.c listen.c parse.c error.c prompt.c \
	request_tbl.c list_rqs.c pager.c requests.c \
	data.c

# for mk_cmds program

MKCMDSOBJS=	mk_cmds.o utils.o options.o ct.tab.o cmd_tbl.o

MKCMDSFILES=	mk_cmds.c utils.c options.c ct.y cmd_tbl.l

MKCMDSCSRCS=	mk_cmds.c utils.c options.c ct.tab.c cmd_tbl.c

# include files

HFILES=	ss.h ss_internal.h copyright.h

# for 'tags' and dependencies

CFILES=	$(SRCS) $(MKCMDSCSRCS) test.c

# for building archives

FILES=	$(SRCS) $(MKCMDSFILES) $(HFILES) \
	ss_err.et std_rqs.ct Makefile \
	test.c commands.ct ss mit-sipb-copyright.h

#
# stuff to build
#

all:	libss.a mk_cmds libss_p.a llib-lss.ln # lint

dist:	archives

install: all
	install -c -s mk_cmds ${DESTDIR}/usr/athena/mk_cmds
	install -c libss.a ${DESTDIR}/usr/athena/lib/libss.a
	ranlib ${DESTDIR}/usr/athena/lib/libss.a
	install -c libss.a ${DESTDIR}/usr/athena/lib/libss_p.a
	ranlib ${DESTDIR}/usr/athena/lib/libss_p.a
	@rm -rf ${DESTDIR}/usr/include/ss
	@mkdir ${DESTDIR}/usr/include/ss
	cp ss.h ss_err.h ss_internal.h copyright.h ${DESTDIR}/usr/include/ss/
	cp copyright.h ${DESTDIR}/usr/include/ss/mit-sipb-copyright.h
	install -c -m 644 llib-lss.ln ${DESTDIR}/usr/lib/lint/llib-lcom_err.ln

tags:	TAGS

.SUFFIXES:	.ct

.c.o:
	${CC} ${CFLAGS} -p -c $*.c
	mv -f $*.o profiled/$*.o
	$(CC) $(CFLAGS) -c $*.c

std_rqs.c: mk_cmds std_rqs.ct
	./mk_cmds $*.ct

ss_err.o ss_err.h : ss_err.et
	$(ETDIR)compile_et ss_err.et
	rm -f ss_err.o profiled/ss_err.o
	cc -O -c ss_err.c
	cp ss_err.o profiled/ss_err.o

ct.tab.c ct.tab.h: ct.y
	rm -f ct.tab.* y.*
	yacc -d ct.y
	mv -f y.tab.c ct.tab.c
	mv -f y.tab.h ct.tab.h

#
libss.a:	$(OBJS)
	rm -f $@
	ar cruv $@ $(OBJS)
	ranlib $@

libss_p.a:	$(OBJS)
	rm -f $@
	cd profiled;ar cruv ../$@ $(OBJS)
	ranlib $@

libss.o:	$(OBJS)
	ld -r -s -o $@ $(OBJS)
	chmod -x $@

lint:	llib-lss.ln

../et/llib-lcom_err.ln:
	cd ../etc ; make ${MFLAGS} llib-lcom_err.ln

llib-lss.ln:	$(SRCS) ../et/llib-lcom_err.ln
	lint -Css $(LINTSFLAGS) $(SRCS) ../et/llib-lcom_err.ln | \
		egrep -v 'possible pointer alignment problem' | \
		egrep -v 'returns value which is'

mk_cmds:	$(MKCMDSOBJS)
	$(CC) $(CFLAGS) -o $@ $(MKCMDSOBJS) -ll

TAGS:	$(CFILES)
	-etags $(CFILES)

archives: ss.ar ss.tar

ss.ar:	$(FILES)
	ar cru $@ $(FILES)

ss.tar:	$(FILES)
	rm -f $@
	tar crf $@ $(FILES)

test:	test.o commands.o $(LIB)
	${CC} ${CFLAGS} -o test test.o commands.o $(LIB) $(COMERR)

commands.c: mk_cmds commands.ct
	./mk_cmds $*.ct

saber:	${SRCS} ss_err.o std_rqs.o
	saber ${SABEROPTS} ${SRCS} -I../et -G ss_err.o std_rqs.o -lcom_err

clean:	
	rm -f *.o *~ \#* *.bak core \
		ss_err.h ss_err.c ct.tab.c ct.tab.h cmd_tbl.c \
		lex.yy.c y.tab.c \
		libss.a libss_p.a llib-lss.ln mk_cmds \
		ss.ar ss.tar std_rqs.c \
		TAGS test profiled/*.o

# 'make depend' code
depend: $(CFILES) ss_err.h
	touch Make.depend; makedepend -fMake.depend $(CFLAGS) $(CFILES) 


