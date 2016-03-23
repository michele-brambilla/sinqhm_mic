#ifndef _ZEROMQ_H
#define _ZEROMQ_H
#include<stdio.h>
#include <stdint.h>

#include <zmq.h>
#include "controlshm.h"
#include "lwlpmc.h"


extern char zeromq_bind_address[256];
extern int status;
extern void *zmqContext;
extern void *pullSocket;

typedef struct {
  uint32_t ts   : 32;
  uint16_t sync : 16;
  uint16_t x    : 16;
  uint16_t y    : 16;
}  event_t;

typedef struct {
  uint32_t ts      : 32;
  uint16_t sync    : 16;
  uint16_t channel : 4;
  uint16_t pos     : 12;
} debug_t;


int zeromq_init();

void zmqReceive(packet_type*);

extern void process_0mq(event_t*);

#endif //ZEROMQ_H
