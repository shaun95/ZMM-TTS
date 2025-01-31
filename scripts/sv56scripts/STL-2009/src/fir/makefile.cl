# -----------------------------------------------------------------------------
#       MS Visual C makefile for compiling and testing the FIR module.
#       The executable must be defined by variable DEMO and FLTR
#       below.
#       01.May.94 - Implemented by <simao@cpqd.ansp.br> 
#       30.Oct.94 - Updated for half-tilt IRS - <simao@ctd.comsat.com>
#       01.Feb.95 - Updated for new IIR module names - <simao@ctd.comsat.com>
#       31.Jul.95 - Included P.341, Cascade async - <simao@ctd.comsat.com>
#       13.May.97 - Included FIR 5kHz BP filter - <simao@ctd.comsat.com>
#       16.May.97 - Included 1:1 HQ BP filter test - <simao@ctd.comsat.com>
#       05.Jan.99 - Tests for delayed/skipped samples in async operation
#	02.Jul.99 - Added support for MSIN and Rcx Mod IRS 8,16 kHz
# -----------------------------------------------------------------------------

# ------------------------------------------------
# Choose a file comparison utility: 
#       - cf compares, 
#       - sub shows the difference of the different samples
# Default is sub.
# ------------------------------------------------
#CF = cf -q
CF = sub -q -equiv 1
#CF_OPT = 256 1 30

# ------------------------------------------------
# Choose an archiving utility: 
#       - public domain unzip, or [PC/Unix/VMS]
#       - shareware pkunzip [PC only]
# ------------------------------------------------
#UNZIP = pkunzip
UNZIP = unzip -o

# ------------------------------------------------
# Choose an AWK; suggest use GNU version 
#                (available via anonymous ftp) 
# ------------------------------------------------
AWK = gawk
AWK_CMD = '$$6~/[0-9]+:[0-9][0-9]/ {print "sb -over",$$NF};END{print "exit"}'

# ------------------------------------------------
# Choose compiler options.
# ------------------------------------------------
CC_OPT = -I../utl -I../iir -W1

# ------------------------------------------------
# Other symbols
# ------------------------------------------------
RM=rm -f
RUN=
DEMO = $(RUN) firdemo -q
FLTR = $(RUN) filter -q

# ------------------------------------------------
# List of files (source and object)
# ------------------------------------------------
FIR_SRC = fir-dsm.c fir-flat.c fir-irs.c fir-lib.c fir-pso.c fir-tia.c \
	fir-hirs.c fir-wb.c fir-msin.c fir-LP.c
FIR_OBJ = fir-dsm.obj fir-flat.obj fir-irs.obj fir-pso.obj fir-lib.obj \
	fir-tia.obj fir-hirs.obj fir-wb.obj fir-msin.obj fir-LP.obj
IIR_OBJ = iir-lib.obj iir-g712.obj iir-dir.obj iir-flat.obj

# ------------------------------------------------
# Generic rules
# ------------------------------------------------
.c.obj:
	$(CC) $(CC_OPT) -c $<

# ------------------------------------------------
# Targets
# ------------------------------------------------
all: firdemo flt filter 

anyway: clean all

clean:
	$(RM) *.obj 

cleantest:
	$(RM) *.hqp *.flt *.ref test.src

veryclean: clean cleantest
	$(RM) firdemo.exe flt.exe filter.exe

# ------------------------------------------------
# Specific rules
# ------------------------------------------------
filter: filter.exe
filter.exe: filter.obj $(FIR_OBJ) ugst-utl.obj $(IIR_OBJ)
	$(CC) -o filter filter.obj $(FIR_OBJ) ugst-utl.obj $(IIR_OBJ) 

flt:	flt.exe
flt.exe: fltresp.obj $(IIR_OBJ) $(FIR_OBJ)
	$(CC) -o flt fltresp.obj $(IIR_OBJ) $(FIR_OBJ) 

firdemo: firdemo.exe
firdemo.exe: firdemo.obj $(FIR_OBJ) ugst-utl.obj
	$(CC) -o firdemo firdemo.obj $(FIR_OBJ) ugst-utl.obj

ugst-utl.obj: ../utl/ugst-utl.c
	$(CC) $(CC_OPT) -c ../utl/ugst-utl.c

iir-lib.obj: ../iir/iir-lib.c
	$(CC) $(CC_OPT) -c ../iir/iir-lib.c

iir-g712.obj: ../iir/iir-g712.c
	$(CC) $(CC_OPT) -c ../iir/iir-g712.c

iir-dir.obj: ../iir/iir-dir.c
	$(CC) $(CC_OPT) -c ../iir/iir-dir.c

iir-flat.obj: ../iir/iir-flat.c
	$(CC) $(CC_OPT) -c ../iir/iir-flat.c

# ------------------------------------------------
# Dependencies
# ------------------------------------------------
filter.obj:       filter.c firflt.h ../utl/ugstdemo.h
filter-d.obj:     filter-d.c firflt.h ../utl/ugstdemo.h
fltresp.obj:      firflt.h ../iir/iirflt.h ../utl/ugstdemo.h
firdemo.obj:      firdemo.c firflt.h ../utl/ugstdemo.h ../utl/ugst-utl.h

# ------------------------------------------------
# Testing the code
# Note: there are no compliance test vectors associated with the FIR module
# ------------------------------------------------

test: 		proc_fir proc_filter comp_fir comp_filter
proc: 		proc_fir proc_filter
comp: 		comp_fir comp_filter
test_fir: 	proc_fir comp_fir comp_filter
test_filter: 	proc_filter comp_filter

proc_fir: test.src
	$(DEMO) test.src test001.hqp       8 0  0  0  0  0
	$(DEMO) test.src test002.hqp      16 0  0  0  0  0
	$(DEMO) test.src test003.hqp       0 1  0  0  0  0
	$(DEMO) test.src test004.hqp       0 0  2  0  0  0
	$(DEMO) test.src test005.hqp       0 0  3  0  0  0
	$(DEMO) test.src test006.hqp       0 0  0  2  0  0
	$(DEMO) test.src test007.hqp       0 0  0  3  0  0
	$(DEMO) test.src test008.hqp       0 0  0  0  2  0
	$(DEMO) test.src test009.hqp       0 0  0  0  3  0
	$(DEMO) test.src test010.hqp       0 0  0  0  0  2
	$(DEMO) test.src test011.hqp       0 0  0  0  0  3
	$(DEMO) test.src test012.hqp       0 0  2  3  2  3
	$(DEMO) test.src test013.hqp       0 0  3  2  3  2
	$(DEMO) test.src test014.hqp       8 0  2  3  2  3
	$(DEMO) test.src test015.hqp      16 0  2  3  2  3
	$(DEMO) test.src test016.hqp       8 1  2  3  2  3
	$(DEMO) test.src test017.hqp      16 1  2  3  2  3
	$(DEMO) -mod test.src test018.hqp 16 0  0  0  0  0
	$(DEMO) -mod test.src test019.hqp 48 0  0  0  0  0
	$(DEMO) test.src test020.hqp       0 0 -2  0  0  0
	$(DEMO) test.src test021.hqp       0 0  0 -2  0  0
	$(DEMO) test.src test022.hqp       0 0  0  0 -2  0
	$(DEMO) test.src test023.hqp       0 0  0  0  0 -2
	$(DEMO) -ht test.src test024.hqp  16 0  0  0  0  0

comp_fir: test024.ref
#       $(CF) test004.hqp test006.hqp $(CF_OPT)
#       $(CF) test005.hqp test007.hqp $(CF_OPT)
#       $(CF) test008.hqp test010.hqp $(CF_OPT)
#       $(CF) test009.hqp test011.hqp $(CF_OPT)
#       $(CF) test012.hqp test013.hqp $(CF_OPT)
	$(CF) test001.hqp test001.ref $(CF_OPT)
	$(CF) test002.hqp test002.ref $(CF_OPT)
	$(CF) test003.hqp test003.ref $(CF_OPT)
	$(CF) test004.hqp test004.ref $(CF_OPT)
	$(CF) test005.hqp test005.ref $(CF_OPT)
	$(CF) test006.hqp test004.ref $(CF_OPT)
	$(CF) test007.hqp test005.ref $(CF_OPT)
	$(CF) test008.hqp test008.ref $(CF_OPT)
	$(CF) test009.hqp test009.ref $(CF_OPT)
	$(CF) test010.hqp test008.ref $(CF_OPT)
	$(CF) test011.hqp test009.ref $(CF_OPT)
	$(CF) test012.hqp test012.ref $(CF_OPT)
	$(CF) test013.hqp test012.ref $(CF_OPT)
	$(CF) test014.hqp test014.ref $(CF_OPT)
	$(CF) test015.hqp test015.ref $(CF_OPT)
	$(CF) test016.hqp test014.ref $(CF_OPT)
	$(CF) test017.hqp test017.ref $(CF_OPT)
	$(CF) test018.hqp test018.ref $(CF_OPT)
	$(CF) test019.hqp test019.ref $(CF_OPT)
	$(CF) test020.hqp test020.ref $(CF_OPT)
	$(CF) test021.hqp test020.ref $(CF_OPT)
	$(CF) test022.hqp test022.ref $(CF_OPT)
	$(CF) test023.hqp test022.ref $(CF_OPT)
	$(CF) test024.hqp test024.ref $(CF_OPT)

proc_filter: test.src
	$(FLTR) IRS8 test.src irs8.flt
	$(FLTR) IRS16 test.src irs16.flt
	$(FLTR) -mod IRS16 test.src irs16-m.flt
	$(FLTR) IRS48 test.src irs48.flt
	$(FLTR) RXIRS8 test.src rxmirs8.flt
	$(FLTR) RXIRS16 test.src rxmirs16.flt
	$(FLTR) HIRS16 test.src ht-irs16.flt
	$(FLTR) DSM test.src dsm.flt
	$(FLTR) PSO test.src pso.flt
	$(FLTR) GSM1 test.src tst-msin.flt
	$(FLTR) -up HQ2 test.src hq2-up.flt
	$(FLTR) -down HQ2 test.src hq2-dw.flt
	$(FLTR) -up HQ3 test.src hq3-up.flt
	$(FLTR) -down HQ3 test.src hq3-dw.flt
	$(FLTR) -up FLAT test.src flat-up.flt
	$(FLTR) -down FLAT test.src flat-dw.flt
	$(FLTR) FLAT1 test.src testfla1.flt
	$(FLTR) -up PCM test.src pcm-up.flt
	$(FLTR) -down PCM test.src pcm-dw.flt
	$(FLTR) PCM1 test.src pcm1.flt
	$(FLTR) -up iflat test.src test-cas.flt
	$(FLTR) -async iflat test.src test-asy.flt
	$(FLTR) -async -delay 37 iflat test.src tst-asyd.flt
	$(FLTR) -async -delay -37 iflat test.src tst-asys.flt
	$(FLTR) -down iflat test.src test-sac.flt
	$(FLTR) p341 test.src testp341.flt
	$(FLTR) 5kbp test.src test5kbp.flt

comp_filter: test024.ref
	$(CF) irs8.flt          test001.ref  $(CF_OPT)
	$(CF) irs16.flt         test002.ref  $(CF_OPT)
	$(CF) irs16-m.flt       test018.ref  $(CF_OPT)
	$(CF) irs48.flt         test019.ref  $(CF_OPT)
	$(CF) rxmirs8.flt 	rxmirs8.ref  $(CF_OPT)
	$(CF) rxmirs16.flt	rxmirs16.ref $(CF_OPT)
	$(CF) ht-irs16.flt      test024.ref  $(CF_OPT)
	$(CF) dsm.flt           test003.ref  $(CF_OPT)
	$(CF) pso.flt           test-pso.ref $(CF_OPT)
	$(CF) tst-msin.flt	testmsin.ref $(CF_OPT)
	$(CF) hq2-up.flt        test004.ref  $(CF_OPT)
	$(CF) hq2-dw.flt        test008.ref  $(CF_OPT)
	$(CF) hq3-up.flt        test005.ref  $(CF_OPT)
	$(CF) hq3-dw.flt        test009.ref  $(CF_OPT)
	$(CF) flat-up.flt       test020.ref  $(CF_OPT)
	$(CF) flat-dw.flt       test022.ref  $(CF_OPT)
	$(CF) testfla1.flt	testfla1.ref $(CF_OPT)
	$(CF) pcm-up.flt        testpcmu.ref $(CF_OPT)
	$(CF) pcm-dw.flt        testpcmd.ref $(CF_OPT)
	$(CF) pcm1.flt          testpcm1.ref $(CF_OPT)
	$(CF) test-asy.flt      test-asy.ref $(CF_OPT)
	$(CF) test-cas.flt      test-cas.ref $(CF_OPT)
	$(CF) test-sac.flt      test-sac.ref $(CF_OPT)
	$(CF) testp341.flt      testp341.ref $(CF_OPT)
	$(CF) test5kbp.flt      test5kbp.ref $(CF_OPT)
	$(CF) -delay 37  tst-asyd.flt test-asy.flt $(CF_OPT)
	$(CF) -delay -37 tst-asys.flt test-asy.flt $(CF_OPT)

test.src:
	$(UNZIP) test-fir.zip test.src
#	$(UNZIP) -v test-fir.zip test.src | $(AWK) $(AWK_CMD) > x
#	command < x
	swapover test.src

test024.ref:
	$(UNZIP) test-fir.zip *.ref
#	$(UNZIP) -v test-fir.zip *.ref | $(AWK) $(AWK_CMD) > x
#	command < x
	swapover *.ref

shell:
	echo Shell is $(SHELL)
