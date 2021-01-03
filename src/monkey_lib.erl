%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(monkey_lib). 
    
%% --------------------------------------------------------------------
%% Include files

%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions
-define(MasterList,['master@c0','master@c1','master@c2']).
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
-export([candidate_hosts/0,
	 candidate_services/0,
	net_call/4]).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------

candidate_hosts()->
    SdReadAll=net_call(db_sd,read_all,[],?MasterList),
    {N,Hosts}=count_hosts(SdReadAll,0,[]),
    Candidates = if
		     N>1->
			 {N,Hosts};
		     true->
			 []
		 end,
    Candidates.
			
count_hosts([],N,Hosts)->
       {N,Hosts};
count_hosts([{_ServiceId,_ServiceVsn,_AppSpec,_AppSpecVsn,HostId,_VmDir,_VmId,_Vm}|T],N,Acc)->
    case lists:member(HostId,Acc) of
	false->
	    NewN=N+1,
	    NewAcc=[HostId|Acc]; 
	true->
	    NewN=N,
	    NewAcc=Acc
	   end,
    count_hosts(T,NewN,NewAcc).


candidate_services()->
    SdReadAll=net_call(db_sd,read_all,[],?MasterList),
    ServiceCount=count_services(SdReadAll,[]),
    [{ServiceId,ServiceVsn,N,VmList}||{ServiceId,ServiceVsn,N,VmList}<-ServiceCount,
				      N>1].

count_services([],ServiceCount)->
    ServiceCount;
count_services([{ServiceId,ServiceVsn,_AppSpec,_AppSpecVsn,_HostId,_VmDir,_VmId,Vm}|T],Acc)->
    
     case lists:keyfind(ServiceId,1,Acc) of
	false->
	    NewAcc=[{ServiceId,ServiceVsn,1,[Vm]}|Acc]; 
	{ServiceId,ServiceVsn,N,VmList}->
	     
	     NewAcc=lists:keyreplace(ServiceId,1,Acc,{ServiceId,ServiceVsn,N+1,[Vm|VmList]})
     end,
    count_services(T,NewAcc).

%%-------------------------------


net_call(M,F,A,WorkerList)->
    S=self(),
    [spawn(fun()->net_call(M,F,A,Node,S) end)||Node<-WorkerList],
    Result=receive
	       {_Pid,M,F,ack,R}->
		   R
	   after 2*5000 ->
		   {error,[timeout,?FILE]}
	   end,
    Result.


net_call(M,F,A,Node,Parent)->
    case rpc:call(Node,M,F,A,5000) of
	{badrpc,_Reason}->
%	    io:format("{badrpc,Reason} ~p~n",[{Node,badrpc,Reason}]),
	    ok;
	R ->
%	    io:format("R= ~p~n",[{Node,R}]),
	    Parent!{self(),M,F,ack,R}
    end.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
db_sd_read_all()->
    S=self(),
    [spawn(fun()->db_sd_read_all(Node,S) end)||Node<-?MasterList],
    Result=receive
	       {_Pid,db_sd_read_all_ack,R}->
		   R
	   after 2*5000 ->
		   {error,[timeout,?FILE]}
	   end,
    Result.


db_sd_read_all(Node,Parent)->
    case rpc:call(Node,db_sd,read_all,[],5000) of
	{badrpc,_Reason}->
%	    io:format("{badrpc,Reason} ~p~n",[{Node,badrpc,Reason}]),
	    ok;
	R ->
%	    io:format("R= ~p~n",[{Node,R}]),
	    Parent!{self(),db_sd_read_all_ack,R}
    end.
