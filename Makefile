all:
	erlc -o ebin src/*.erl;
	rm -rf ebin/* src/*.beam *.beam;
	rm -rf  *~ */*~  erl_cra*;
	echo Done
doc_gen:
	echo glurk not implemented
stop:
	erl_call -a 'rpc call [s1@c1 init stop []]';
	erl_call -a 'rpc call [master@c2 init stop []]'
test:
	rm -rf ebin/* src/*.beam *.beam;
	rm -rf  *~ */*~  erl_cra*;
	cp src/*.app ebin;
	erlc -o ebin src/*.erl;
	erl -pa ebin -s global_test start -sname global_test -setcookie abc
