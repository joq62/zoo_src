%% This is the application resource file (.app file) for the 'base'
%% application.
{application,s1,
[{description, "s1 " },
{vsn, "1.0.0" },
{modules, 
	  [s1_app,s1_sup,s1]},
{registered,[s1]},
{applications, [kernel,stdlib]},
{mod, {s1_app,[]}},
{start_phases, []}
]}.
