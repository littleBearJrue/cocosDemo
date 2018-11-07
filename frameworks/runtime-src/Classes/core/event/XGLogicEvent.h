#ifndef __XG_LOGIC_EVENT_H__
#define __XG_LOGIC_EVENT_H__

#include "XGEvent.h"

class XGLogicEvent 
	: public XGEvent
{
public:
	XGLogicEvent(int nid)
		:XGEvent(nid)
	{
	}
public:
	enum 
	{
		EVENT_LOGIC_START = XGEvent::XG_EVENT_LOGIC,

		EVENT_APP = EVENT_LOGIC_START + 2000,
		EVENT_APP_LAUNCHING,
		EVENT_APP_LAUNCHED,
		EVENT_APP_ENTER_BACKGROUND,
		EVENT_APP_ENTER_FOREGROUND,
		EVENT_APP_EXITING,
		EVENT_APP_EXITED,

		EVENT_TIME_DELAY_EVENT,

		EVENT_SOCKET,


		EVENT_PLAYER_START = EVENT_LOGIC_START + 4000,
		EVENT_PLAYER_SIT,
		EVENT_PLAYER_STAND,
		EVENT_PLAYER_CHIPIN,
		EVENT_PLAYER_LOGIN_SUCCESS,
		EVENT_PLAYER_START_CHIPIN,
		EVENT_PLAYER_END_CHIPIN,
		
		
	};
};



class XGEventSocket : public XGLogicEvent
{
public:
	XGEventSocket(int socketEvent, void *argv)
		: XGLogicEvent(XGLogicEvent::EVENT_SOCKET)
		, m_nSocketEvent(socketEvent)
		, m_argv(argv)
	{

	}

	int m_nSocketEvent;
	void *m_argv;
};

class XGEventTimeDelayEvent : public XGLogicEvent
{
public:
	XGEventTimeDelayEvent(void * obj, XGEventTimeHandlerPtr func, float delayTime)
		: XGLogicEvent(XGLogicEvent::EVENT_TIME_DELAY_EVENT)
		, m_pObj(obj)
		, m_pFunc(func)
	{
		m_nStartTime =  clock();
		m_fDelayTime = delayTime;
	}
	void *m_pObj;
	XGEventTimeHandlerPtr m_pFunc;

};







#endif