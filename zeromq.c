#include <assert.h>
#include <string.h>

#include "zeromq.h"
#include "process_common.h"

char zeromq_bind_address[256];
int status;
void *zmqContext = NULL;
void *pullSocket = NULL;


static event_t* RawDataBuffer = NULL;

extern volatile unsigned int *shm_cfg_ptr;

int zeromq_init() {


  printf("================================\n");
  printf("\t zeromq init \n");
  printf("================================\n");
  printf("zmq receiver bind address: %s\n",zeromq_bind_address);
  
  zmqContext = zmq_ctx_new();
  pullSocket = zmq_socket(zmqContext,ZMQ_PULL);
  assert(pullSocket);

  printf("================================\n");
  printf("\t zeromq socket = %p \n",pullSocket);
  printf("================================\n");

  status = -1;
  status = zmq_connect(pullSocket,zeromq_bind_address);
  assert(status == 0);
  
  printf("================================\n");
  printf(" zeromq connection status = %d \n",status);
  printf("================================\n");

  /* status = zmq_setsockopt (pullSocket, ZMQ_SUBSCRIBE, */
  /*                          "", 0); */

  printf("================================\n");
  printf(" zeromq sockopt status = %d \n",status);
  printf("================================\n");

  assert(status == 0);
  
  
  printf("================================\n");
  printf("\t connection established \n");
  printf("================================\n");


  return status;

}



void zeromq_close() {
  zmq_close(pullSocket);
  zmq_ctx_destroy(zmqContext);
}





void zmqReceive(packet_type* p) {
  static unsigned long PulseId=0;
  unsigned long oldPulseId=0;
  uint32 binpos;
  char headerData[1024];
  int bytesRead,nEvents;
  static int maxEvents = -1;

  uint32 timestamp;
  int32  i = 0;
  
  oldPulseId = PulseId;
  
  bytesRead = zmq_recv(pullSocket, headerData, sizeof(headerData),0);
  if(bytesRead >= sizeof(headerData)) {
    headerData[sizeof(headerData)-1] = '\0';
  } else {
    headerData[bytesRead] = '\0';
  }
  
  p->ptr = 1;
  p->header_found = 1;
  shm_cfg_ptr[CFG_FIL_TSI_HEADER] = headerData;
  
  /* printf("%s\n",headerData); */
  char *token;
  token = strtok(headerData,",");
  while( token ) {
    if(strstr(token,"pid")) {
      PulseId=atoi(token+6);
    }
    if(strstr(token,"ne")) {
      nEvents=atoi(token+5);
    }
    token = strtok(NULL,",");
  }
  /* printf("\nPulseId = %d\n",PulseId); */
  
  
  //////////////////////////
  // Here recv data
  // attenzione ad allorare la dimensione corretta:
  // facciamo on-the-fly?
  // o un grosso chunk e usiamo quello che serve?
  // normalmente lo farebbe zeroHM()
      
  if( maxEvents < nEvents ) {
    maxEvents = nEvents;
        
    if( RawDataBuffer != NULL) {
      free(RawDataBuffer);
    }
    RawDataBuffer = malloc(nEvents*sizeof(event_t));
  }
      
  bytesRead += zmq_recv(pullSocket,
                        RawDataBuffer,
                        nEvents*sizeof(event_t),
                        0); 
  
  if (!shm_cfg_ptr[CFG_SRV_DAQ_PAUSE_CMD]) {
    
    if(PulseId-oldPulseId > 1) {
      shm_cfg_ptr[CFG_FIL_PKG_INCOMPLETE] += (PulseId-1)-oldPulseId;
    }

    p->length = nEvents;
    // RawDataBuffer -> histo
    printf("nEvents = %d\n",p->length);
    /* if( p->data != NULL ) { */
    /*   printf("size(p->data) = %d\n",sizeof(p->data)); */
    /*   //memcpy(p->data,RawDataBuffer,nEvents*sizeof(event_t)); */
    /*   p->data[0] = RawDataBuffer[0]; */
    /* } */
    
    
    // bytes read += ...
    shm_cfg_ptr[CFG_FIL_PKG_READ]++;



  }
  else {
    p->length = 0;
    // do something
  }

  printf("sizeof(RawDataBuffer) = %d\n",sizeof(RawDataBuffer));
  
  for(p->ptr = 0 ;p->ptr < p->length; ++p->ptr) {
    p->data[0] = RawDataBuffer[p->ptr].ts;
    p->data[1] = RawDataBuffer[p->ptr].sync;
    p->data[2] = RawDataBuffer[p->ptr].x;
    p->data[3] = RawDataBuffer[p->ptr].y;

    process_packet_fcn(p+i);

    /* timestamp = RawDataBuffer[i].ts; */
    /* printf("timestamp = %d\n",timestamp); */
    
    /* binpos = RawDataBuffer[i].x + 128*RawDataBuffer[i].y; */
    /* printf ("binpos = %d\n",binpos); */
     /* UINT32_INC_CEIL_CNT_OVL(histoDataPtr[binpos], shm_cfg_ptr[CFG_FIL_BIN_OVERFLOWS]); */
  }
  

} // receive

