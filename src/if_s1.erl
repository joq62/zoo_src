%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(if_s1). 
    
%% --------------------------------------------------------------------
%% Include files

%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions

%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
-export([add/2,
	 add_1/2,
	 add_2/2,
	 add_3/2,
	 add_4/2
	]).
 
-export([ping/0
	]).


%% ====================================================================
%% External functions
%% ====================================================================
%%-----------------------------------------------------------------------
ping()->
    {Time,Value}=timer:tc(rpc,call,[get_node(),gen_server,call,[s1, {ping},infinity],5000]),
    io:format("ping time  ~p~n",[Time]),		      
    Value.
		      
add(A,B)->
    A+B.
add_1(A,B)->
    {Time,Value}=timer:tc(gen_server,call,[s1, {add,A,B},infinity]),
    io:format("direct server call  time  ~p~n",[Time]),		      
    Value.

add_2(A,B)->
    {Time,Value}=timer:tc(rpc,call,[node(),gen_server,call,[s1, {add,A,B},infinity],5000]),
    io:format("rpc node()  time  ~p~n",[Time]),		      
    Value.
add_3(A,B)->
    {Time,Value}=timer:tc(rpc,call,['s1@c2',gen_server,call,[s1, {add,A,B},infinity],5000]),
    io:format("rpc 's1@c2' time  ~p~n",[Time]),		      
    Value.
add_4(A,B)->
    {Time,Value}=timer:tc(rpc,call,[get_node(),gen_server,call,[s1, {add,A,B},infinity],5000]),
    io:format("rpc get_node() time  ~p~n",[Time]),		      
    Value.

	

	
    
%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
get_node()->
    {ok,HostId}=net:gethostname(),
    list_to_atom("s1@"++HostId).
