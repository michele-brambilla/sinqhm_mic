/*******************************************************************************
  sinqhmlog.h
*******************************************************************************/
/**
 * This file belongs to the SINQ histogram memory implementation for 
 * LINUX-RTAI. We need some form of logging. We define a logging function
 * here, different interface adapters to whatever server is used may choose 
 * implement this differently.
 * 
 * Mark Koennecke, Gerd Theidel, September 2005
 */

#ifndef _SINQHMLOG_H_
#define _SINQHMLOG_H_


/*******************************************************************************
  function prototypes
*******************************************************************************/

void sinqhmlog(char *fmt, ...);


/******************************************************************************/

#endif //_SINQHMLOG_H_
