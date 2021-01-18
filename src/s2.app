%% This is the application resource file (.app file) for the 'base'
%% application.
{application,s2,
[{description, "s2 " },
{vsn, "1.0.0" },
{modules, 
	  [s2_app,s2_sup,s2]},
{registered,[s2]},
{applications, [kernel,stdlib]},
{mod, {s2_app,[]}},
{start_phases, []}
]}.
