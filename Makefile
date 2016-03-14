#-------------------------------------------------------------------------------
# makefile for Linux/RTAI SINQHM server
#-------------------------------------------------------------------------------

SHELL = /bin/sh

#-------------------------------------------------------------------------------
# Path to source files
#-------------------------------------------------------------------------------

SRC_PATH=../../src


vpath %.c   $(SRC_PATH)
vpath %.cpp $(SRC_PATH)
vpath %.h   $(SRC_PATH)
vpath %.s   $(SRC_PATH)


#-------------------------------------------------------------------------------
# Filler Application
#-------------------------------------------------------------------------------

FIL_MAIN = filler_main.c

FIL_SRC = datashm.c          \
          controlshm.c       \
          debugshm.c         \
          lwlpmc.c           \
          process_dig.c      \
          process_hrpt.c     \
          process_psd.c      \
          process_tof.c      \
          process_tofmap.c   \
          process_sans2.c    \
          process_common.c   \
          rawdata.c


# FIL_INLINE = -D_INLINE

FIL_DIR = ./rt

FIL_MAIN_OBJ = $(FIL_MAIN:%.c=$(FIL_DIR)/%.o)
FIL_OBJ      = $(FIL_SRC:%.c=$(FIL_DIR)/%.o)


#-------------------------------------------------------------------------------
# Server Application
#-------------------------------------------------------------------------------

APPWEB_VER = 2.4.2
#APPWEB_VER = 2.0.4


APPWEB_DEF = -D_DEBUG  -DLINUX -D_REENTRANT -DAPPWEB_VER_$(subst .,_,$(APPWEB_VER))
APPWEB_LIB = appWebStatic-$(APPWEB_VER)
APPWEB_INC = ../../include/appWeb-$(APPWEB_VER)



SRV_SRC = sinqhmegi.c    \
          egiadapter.c   \
          sinqhmsrv.c    \
          datashm.c      \
          controlshm.c   \
          nxdataset.c    \
          stptok.c       \
          debugshm.c     \
          lwlpmc.c

SRV_SRC_PP = appWrapper.cpp

SRV_DIR = ./ua

SRV_APP = $(SRV_DIR)/sinqhmegi

SRV_OBJ = $(SRV_SRC:%.c=$(SRV_DIR)/%.o)  $(SRV_SRC_PP:%.cpp=$(SRV_DIR)/%.o)

SRV_DBG = -g

#-------------------------------------------------------------------------------
# VME LWL TestGen
#-------------------------------------------------------------------------------

VLT_SRC = vmelwl.c vme_testgen.c

VLT_DIR = ./vlt

VLT_APP = $(VLT_DIR)/vmetgen

VLT_OBJ = $(VLT_SRC:%.c=$(VLT_DIR)/%.o)


#-------------------------------------------------------------------------------
# target architecture dependant settings
#-------------------------------------------------------------------------------


#---------------------------
# x86 opts 
#---------------------------
ifeq ($(fil_target),rtai_x86)

APPWEB_LIB = appWebStatic

TARGET_DEFINED = 1
#
# Realtime Application
#

FIL_APP = $(FIL_DIR)/sinqhm_filler.o

FIL_INC = -I. -I$(SRC_PATH) \
          -I /usr/realtime/include \
          -I/usr/src/linux/include
FIL_DEF = -DAPP_FILLER -DARCH_X86 -DFILLER_RTAI -D__KERNEL__ -DMODULE -DEXPOFIL_SYMTAB 
FIL_FLG = -Wall -Wstrict-prototypes -Wno-trigraphs -O3 -fno-strict-aliasing -fno-common -fomit-frame-pointer -pipe -mpreferred-stack-boundary=2 -march=i686  -finline-functions -finline-limit=60000  -frerun-loop-opt 

#
# Server Application
#
SRV_INC = -I. \
          -I /usr/realtime/include \
          -I ../../include  -I $(APPWEB_INC)
SRV_DEF = -DAPP_SERVER -DARCH_X86 -DFILLER_RTAI $(APPWEB_DEF)
SRV_FLG =  $(SRV_DBG) -Wall
SRV_LIB = -L../../lib/x86 -lmxml  -l$(APPWEB_LIB) -lpthread -ldl

endif

#---------------------------
# ppc opts 
#---------------------------
ifeq ($(fil_target),rtai_ppc)

TARGET_DEFINED = 1
#
# Realtime Application
#

FIL_APP = $(FIL_DIR)/sinqhm_filler.o

FIL_INC = -I. -I$(SRC_PATH) \
         -I$(ELINOS_PROJECT)/rtai/install/include \
         -I$(ELINOS_PROJECT)/linux/include \
         -I$(ELINOS_PROJECT)/linux/arch/ppc

FIL_DEF = -DAPP_FILLER -DARCH_PPC -DFILLER_RTAI -D__KERNEL__ -DMODULE -DEXPOFIL_SYMTAB  -DTIME_CONSUMING_DEBUG
FIL_FLG = -Wall -Wstrict-prototypes -Wno-trigraphs -O4 -fno-strict-aliasing -fno-common -fomit-frame-pointer -fsigned-char -msoft-float -pipe -ffixed-r2 -Wno-uninitialized -mmultiple -mstring  -finline-functions -finline-limit=60000  -frerun-loop-opt 

# -finline-functions -finline-limit=6000 -frerun-loop-opt -funroll-loops
# -fomit-frame-pointer
# -finline-functions   -finline-limit=6000  (default: 600)
# -frerun-loop-opt -funroll-loops -funroll-all-loops 
# used in vxworks:
#  = -ansi -nostdinc  -mstrict-align  -fno-builtin -fno-for-scope 

#
# Server Application
#
SRV_DEF = -DAPP_SERVER -DARCH_PPC -DFILLER_RTAI $(APPWEB_DEF)
SRV_FLG = $(SRV_DBG) -Wall
SRV_INC = -I$(ELINOS_PROJECT)/rtai/install/include\
         -I ../../include -I $(APPWEB_INC)
SRV_LIB = -L../../lib/ppc -lmxml  -l$(APPWEB_LIB) -static -lpthread -ldl


# VLT_DEF = -DAPP_SERVER -DARCH_PPC -DFILLER_RTAI $(APPWEB_DEF)
VLT_FLG = -g -Wall

VLT_INC = -I$(ELINOS_PROJECT)/rtai/install/include \
          -I$(ELINOS_PROJECT)/linux/include \
          -I ../../include -I $(APPWEB_INC)

#VLT_LIB = -L../lib/ppc  -lpthread -ldl

endif


#----------------------------------------
# filler in linux user space 
#----------------------------------------
ifeq ($(fil_target),user_x86)

TARGET_DEFINED = 1
APPWEB_LIB = appWebStatic

#
# (Non-)Realtime Application
#

FIL_APP = $(FIL_DIR)/sinqhm_filler

FIL_INC = -I. \
         -I ../../include  -I $(APPWEB_INC)
FIL_DEF = -DAPP_FILLER -DARCH_X86 -DFILLER_USER $(APPWEB_DEF)
FIL_FLG =  $(SRV_DBG) -Wall

RA_LIB = -L../lib/x86 -lmxml  -lappWebStatic -lpthread -ldl


#
# Server Application
#
SRV_INC = -I. \
         -I ../../include  -I $(APPWEB_INC)
SRV_DEF = -DAPP_SERVER -DARCH_X86 -DFILLER_USER $(APPWEB_DEF)
SRV_FLG =  $(SRV_DBG) -Wall
SRV_LIB = -L../../lib/x86 -lmxml  -l$(APPWEB_LIB) -lpthread -ldl
# SRV_LIB = -L../lib/x86 -lmxml  -lappWebStatic -lstdc++ -lpthread -ldl

endif



#-------------------------------------------------------------------------------
# Check for valid fil_target
#-------------------------------------------------------------------------------

ifndef TARGET_DEFINED
ifndef fil_target
$(error ERROR: variable $$(fil_target) not defined)
else
$(error ERROR: invalid target: $$(fil_target)="$(fil_target)")
endif
endif


################################################################################
#
#  Rules 
#
################################################################################

all:  $(FIL_APP) $(SRV_APP) $(VLT_APP) install 
#  clean

vmelwl:  $(VLT_APP)
	echo 	-cp $(VLT_APP) /tftpboot/nfs/home/theidel

#-------------------------------------------------------------------------------

.PHONY : clean
clean:
	-rm -f $(SRV_DIR)/*.o $(SRV_DIR)/*.d $(SRV_APP) $(FIL_DIR)/*.o $(FIL_DIR)/*.d $(FIL_APP)
	-rm -f $(VLT_DIR)/*.o $(VLT_DIR)/*.d $(VLT_APP)
#-------------------------------------------------------------------------------

.PHONY : install

install: $(FIL_APP) $(SRV_APP) $(VLT_APP)
	-cp $(FIL_APP) ../../distrib/sinqhm
	-cp $(SRV_APP) ../../distrib/sinqhm
	-cp $(VLT_APP) ../../distrib/sinqhm
	ppc_60x-strip ../../distrib/sinqhm/sinqhmegi
	ppc_60x-strip ../../distrib/sinqhm/vmetgen

ifeq "$(fil_target)" "rtai_ppc"
#	-cp -r ../distrib/server   /tftpboot/nfs/home/theidel
#	-cp ../src/*          /tftpboot/nfs/home/src
endif

#-------------------------------------------------------------------------------

$(FIL_DIR):
	mkdir -p $(FIL_DIR)

# recompile FIL_MAIN_OBJ if any FIL_OBJ has changed, since Date and Time 
# is compiled int FIL_MAIN_OBJ
$(FIL_MAIN_OBJ) : $(FIL_MAIN) $(FIL_OBJ)
	$(CC) -c $(FIL_INLINE) $(FIL_INC) $(FIL_DEF) $(FIL_FLG)    $< -o $@

$(FIL_DIR)/%.o : %.c
	$(CC) -c $(FIL_INC) $(FIL_DEF) $(FIL_FLG)    $< -o $@


ifeq "$(fil_target)" "user_x86"

$(FIL_APP):  $(FIL_DIR) $(FIL_MAIN_OBJ) $(FIL_OBJ)
	$(CC) $(FIL_MAIN_OBJ) $(FIL_OBJ) -o $@

else

$(FIL_APP):  $(FIL_DIR) $(FIL_MAIN_OBJ) $(FIL_OBJ)
	$(LD) -r -static $(FIL_MAIN_OBJ) $(FIL_OBJ) -o $@

endif

#-------------------------------------------------------------------------------

$(SRV_DIR):
	mkdir -p $(SRV_DIR)

$(SRV_DIR)/%.o : %.c
	$(CC) -c $(SRV_INC) $(SRV_DEF) $(SRV_FLG)    $< -o $@

$(SRV_DIR)/%.o : %.cpp
	$(CXX) -c $(SRV_INC) $(SRV_DEF) $(SRV_FLG)    $< -o $@

$(SRV_APP): $(SRV_DIR) $(SRV_OBJ)
	$(CXX)  $(SRV_DBG) $(SRV_OBJ) $(SRV_LIB) -o $@

#-------------------------------------------------------------------------------

$(VLT_DIR):
	mkdir -p $(VLT_DIR)

$(VLT_DIR)/%.o : %.c
	$(CC) -c $(VLT_INC) $(VLT_DEF) $(VLT_FLG)    $< -o $@

$(VLT_APP): $(VLT_DIR) $(VLT_OBJ)
	$(CXX) -static $(VLT_DBG) $(VLT_OBJ) $(VLT_LIB) -o $@


#---------------------------------------------------------------------------
# generate dependency file for each C source file
#---------------------------------------------------------------------------

SED_FIL_DIR = $(subst /,\/,$(FIL_DIR))\/

$(FIL_DIR)/%.d : %.c
	$(SHELL) -ec 'mkdir -p $(FIL_DIR) && $(CC) -M $(FIL_INC) $(FIL_DEF) $(FIL_FLG) $< \
		| sed '\''s/^$*\.o[	 ]*:/$(SED_FIL_DIR)$*.o $(SED_FIL_DIR)$*.d : /g'\'' > $@'

SED_SRV_DIR = $(subst /,\/,$(SRV_DIR))\/

$(SRV_DIR)/%.d : %.c
	$(SHELL) -ec 'mkdir -p $(SRV_DIR) && $(CC) -M $(SRV_INC) $(SRV_DEF) $(SRV_FLG) $< \
		| sed '\''s/^$*\.o[	 ]*:/$(SED_SRV_DIR)$*.o $(SED_SRV_DIR)$*.d : /g'\'' > $@'

$(SRV_DIR)/%.d : %.cpp
	$(SHELL) -ec 'mkdir -p $(SRV_DIR) && $(CC) -M $(SRV_INC) $(SRV_DEF) $(SRV_FLG) $< \
		| sed '\''s/^$*\.o[	 ]*:/$(SED_SRV_DIR)$*.o $(SED_SRV_DIR)$*.d : /g'\'' > $@'

SED_VLT_DIR = $(subst /,\/,$(VLT_DIR))\/

$(VLT_DIR)/%.d : %.c
	$(SHELL) -ec 'mkdir -p $(VLT_DIR) && $(CC) -M $(VLT_INC) $(VLT_DEF) $(VLT_FLG) $< \
		| sed '\''s/^$*\.o[	 ]*:/$(SED_VLT_DIR)$*.o $(SED_VLT_DIR)$*.d : /g'\'' > $@'


include $(FIL_OBJ:.o=.d) $(SRV_OBJ:.o=.d) $(SRV_VLT:.o=.d)

#-------------------------------------------------------------------------------