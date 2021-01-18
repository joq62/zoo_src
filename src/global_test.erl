%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(global_test). 
    
%% --------------------------------------------------------------------
%% Include files

%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions
-define(MasterList,['master@c0','master@c1','master@c2']).
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]).



%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    ?debugMsg("Start setup"),
    ?assertEqual(ok,setup()),
    ?debugMsg("stop setup"),
    
    ?debugMsg("Start test_1"),
    ?assertEqual(ok,test_1()),
    ?debugMsg("stop test_1"),
    
   
      %% End application tests
 %   ?debugMsg("Start cleanup"),
  %  ?assertEqual(ok,cleanup()),
  %  ?debugMsg("Stop cleanup"),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
test_1()->
    io:format("********** ~p *****************~n",[time()]),		      
    {Time,42}=timer:tc(if_s1,add,[20,22]),
    io:format("add_3 time  ~p~n",[Time]),		      
    42=if_s1:add_1(20,22),
    42=if_s1:add_2(20,22), 
    42=if_s1:add_3(20,22),
    42=if_s1:add_4(20,22),
 
    timer:sleep(1000),
    test_1(),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
    io:format("Kill S1 ~p~n",[rpc:call('s1@c2',init,stop,[],1000)]),
    io:format("Kill S2 ~p~n",[rpc:call('s2@c2',init,stop,[],1000)]),
   
    ok=application:start(s1),
     
    {ok,HostId}=net:gethostname(),
    {ok,S1}=slave:start(HostId,"s1","-pa ebin -setcookie abc"),
    io:format("S1 ~p~n",[S1]),
    ?assertMatch(pong,net_adm:ping(S1)),
    ?assertMatch(ok,rpc:call(S1,application,start,[s1],2000)),
    ?assertMatch({pong,'s1@c2',s1},if_s1:ping()),

    {ok,S2}=slave:start(HostId,s2,"-pa ebin -setcookie abc -detached"),
    ?assertMatch(pong,net_adm:ping(S2)),
    ?assertMatch(ok,rpc:call(S2,application,start,[s2],2000)),
    ?assertMatch({pong,'s2@c2',s2},rpc:call(S2,s2,ping,[],2000)),
    42=rpc:call('s2@c2',s2,minus,[62,20],200),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
cleanup()->
    init:stop(),
    ok.


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
