%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(calc_service). 
    
%% --------------------------------------------------------------------
%% Include files

%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions
-define(MasterList,['master@c0','master@c1','master@c2']).
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
-export([add/2]).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
add(A,B)->
    WorkerNodes=net_call(db_sd,get,["calc"],?MasterList),
    Result=net_call(calc,add,[A,B],WorkerNodes),
    Result.
    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
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
