# Makefile for RISCV cpu design lab
RTL= -f ./files.f
SEED = 1
#COVERAGE= -cm line+cond+fsm+tgl -cm_hier rv_hier
COVERAGE=
default: clean test

test: compile run

run:
	./simv +vcs+loopdetect +vcs+loopreport -l simv.log +ntb_random_seed=$(SEED) $(COVERAGE)

compile :
	vcs \
	-f ./files.f \
	-timescale=1ns/1ps \
	-full64 +vc +v2k -sverilog -debug_all \
	-LDFLAGS -Wl,--no-as-needed \
	-cm line+cond+tgl+fsm \
	-P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab \
	${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a \
	-timescale=1ns/1ps +notimingchecks +nospecify \
	| tee compile.log

clean:
	rm -rf simv* csrc* *.tmp *.vpd *.key *.log *.fsdb novas.fsdb* verdiLog stack.info*

help:
	@echo "==============================================================================="
	@echo " "
	@echo " USAGE: make target <SEED=xxx> "
	@echo " "
	@echo " ------------------------- Test TARGETS --------------------------- "
	@echo " test    => Compiles TB and GOOD DUT files, runs the simulation. "
	@echo " compile => Compiles the TB and DUT. "
	@echo " run     => Runs the simulation. "
	@echo " clean   => Removes all intermediate simv and log files. "
	@echo " "
	@echo " ------------------------- ADMINISTRATIVE TARGETS --------------------------- "
	@echo " help    => Displays this message. "
	@echo " "
	@echo "==============================================================================="

verdi:
	verdi -autoalias -2012 -nologo -f files.f &