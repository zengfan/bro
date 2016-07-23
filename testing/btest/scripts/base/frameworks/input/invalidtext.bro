# @TEST-EXEC: btest-bg-run bro bro -b %INPUT
# @TEST-EXEC: btest-bg-wait 10
# @TEST-EXEC: btest-diff out
# @TEST-EXEC: sed 1d .stderr > .stderrwithoutfirstline
# @TEST-EXEC: TEST_DIFF_CANONIFIER=$SCRIPTS/diff-remove-abspath btest-diff .stderrwithoutfirstline

@TEST-START-FILE input.log
#separator \x09
#fields	i	c
#types	int	count
	l
	5
@TEST-END-FILE

redef exit_only_after_terminate = T;

global outfile: file;

module A;

type Idx: record {
	i: string;
};

type Val: record {
	c: count;
};

global servers: table[string] of Val = table();

event handle_our_errors(desc: Input::TableDescription, msg: string, level: Reporter::Level)
	{
	print outfile, "Event", msg, level;
	}

event bro_init()
	{
	outfile = open("../out");
	# first read in the old stuff into the table...
	Input::add_table([$source="../input.log", $name="ssh", $error_ev=handle_our_errors, $idx=Idx, $val=Val, $destination=servers]);
	}

event Input::end_of_data(name: string, source:string)
	{
	print outfile, servers;
	Input::remove("ssh");
	terminate();
	}
