%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(monkey_normal_test).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
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
    ?assertEqual(ok,test_1(ok)),
    ?debugMsg("stop test_1"),
    
   
      %% End application tests
    ?debugMsg("Start cleanup"),
    ?assertEqual(ok,cleanup()),
    ?debugMsg("Stop cleanup"),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
test_1(State)->
    case  rpc:call(node(),calc_service,add,[20,22],5000) of
	42->
	    case State of
		error->
		    io:format("calc:add(20,22) = ~p~n",[{time(), 42}]),
		    NewState=ok;
		ok->
		    NewState=State
	    end;
	Reason->
	    case State of
		ok->
		    io:format("Error calc:add(20,22) = ~p~n",[{time(),Reason}]),
		    NewState=error;
		error->
		    NewState=State
	    end
    end,
    timer:sleep(5000),
    test_1(NewState).





monkey_1()->
    case rand:uniform(2) of
	1-> % kill host
	 %   io:format("Kill Host ~p~n",[time()]),
	    FaultCase=case rpc:call(node(),monkey_lib,candidate_hosts,[],5000) of
			  {badrpc,_Reason}->
			      %io:format("badrpc ~p~n",[{time(),Reason}]),
			      no_action;
			  []->
			     % io:format("Too few hosts no action ~p~n",[time()]),
			      no_action;
			  {N,Hosts} ->
			      Position=rand:uniform(N),
			      HostId=lists:nth(Position,Hosts),
			      MasterNode=list_to_atom("master@"++HostId),
			   %   io:format("{N,Hosts} ~p~n",[{N,Hosts}]),
			   %   io:format("Position, HostId, MasterNode ~p~n",[{Position, HostId, MasterNode}]),
			      rpc:call(MasterNode,init,stop,[],5000),
			    %  io:format("MasterNode stopped  ~p~n",[{time(),MasterNode}]),
			      {failure,["stopped master",master,MasterNode]}
		      end;
	2 ->
 	     FaultCase=case rpc:call(node(),monkey_lib,candidate_services,[],5000) of
			   {badrpc,_Reason}->
			     %  io:format("badrpc ~p~n",[{time(),Reason}]);
			       no_action;
			   []->
			      % io:format("Too few services no action ~p~n",[time()]),
			       no_action;
			   ServiceListAll->
			       ServiceList=[{XServiceId,XServiceVsn,XN,XVmList}||{XServiceId,XServiceVsn,XN,XVmList}<-ServiceListAll,
										 XServiceId/="master"],
			       NumServices=lists:flatlength(ServiceList),
			       case NumServices of
				   0->
				      % io:format("Too few services no action ~p~n",[time()]),
				       no_action;
				   NumServices->
				       Position=rand:uniform(NumServices),
				       {ServiceId,_ServiceVsn,N,VmList}=lists:nth(Position,ServiceList),
				       PositionVm=rand:uniform(N),
				       Vm=lists:nth(PositionVm,VmList),
				       
			%	       io:format("ServiceList ~p~n",[ServiceList]),
			%	       io:format("Position, ServiceId, PositionVm, Vm ~p~n",[{Position, ServiceId, PositionVm, Vm}]),
			%	       
				       rpc:call(Vm,application,stop,[list_to_atom(ServiceId)],5000),
			%	       io:format("Application stopped  ~p~n",[{time(),ServiceId,Vm}])
				       {failure,["stopped service",ServiceId,Vm]}
			       end
		       end
    end,
    case rpc:call(node(),calc_service,add,[20,22]) of
	42->
	    ok;
	CalcAddError->
	    case FaultCase of
		no_action->
		    ok;
		{failure,Info}->
		    io:format("FaultCase caused ~p~n",[{time(),{failure,Info}}]),
		    io:format("Error in calc_service:add(20,22)  ~p~n",[{CalcAddError}])
	    end
    end,
    TimeToNextAction=10*rand:uniform(5)+80*1000,
    timer:sleep(TimeToNextAction*1000),
    monkey_1().
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
    spawn(fun()->monkey_1() end),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
  
    init:stop(),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
