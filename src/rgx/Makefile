# Makefile for Henry Spencer/Tcl regex library adjusted for use in XPCE

CC=gcc
COFLAGS=-Wall -g -DREG_DEBUG
CWFLAGS=
CIFLAGS=-I. -I../../linux -I.. -DHAVE_CONFIG_H -DNOPCE
CMFLAGS=
CFLAGS=$(CWFLAGS) $(COFLAGS) $(CIFLAGS) $(CMFLAGS)
AR=ar
RANLIB=ranlib
RM=rm

OBJS= 		regcompW.o regexecW.o regfree.o regerror.o
# OBJS= regcompA.o regexecA.o regcompW.o regexecW.o regfree.o regerror.o

all:		libregex.a test

libregex.a:	$(OBJS)
		rm -f $@
		$(AR) cq $@ $(OBJS)
		$(RANLIB) $@

regcompA.o:
		$(CC) $(CFLAGS) -c -o $@ regcomp.c
regcompW.o:
		$(CC) $(CFLAGS) -DREG_WIDE -c -o $@ regcomp.c
regexecA.o:
		$(CC) $(CFLAGS) -c -o $@ regexec.c
regexecW.o:
		$(CC) $(CFLAGS) -DREG_WIDE -c -o $@ regexec.c
regfree.o:
		$(CC) $(CFLAGS) -DREG_WIDE -c -o $@ regfree.c
regerror.o:
		$(CC) $(CFLAGS) -DREG_WIDE -c -o $@ regerror.c


# mark inclusion dependencies between .c files explicitly
regcompA.o: regcomp.c regc_lex.c regc_color.c regc_nfa.c regc_cvec.c regc_locale.c
regcompW.o: regcomp.c regc_lex.c regc_color.c regc_nfa.c regc_cvec.c regc_locale.c

regexecA.o: regexec.c rege_dfa.c
regexecW.o: regexec.c rege_dfa.c

test:		test.c libregex.a
		$(CC) -o $@ test.c libregex.a

clean: 
		$(RM) -f *~ $(OBJS)
