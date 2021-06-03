#!/usr/local/bin/perl
# emby-lib.pl
# Common functions for the Emby daemon

BEGIN { push(@INC, ".."); };
use WebminCore;
&init_config();

# get_emby_version()
sub get_emby_version
{
	my $getversion = "$config{'version_cmd'}";
	my $version = `$getversion`;
}

# get_stat_icons()
my $okicon = "/images/ok.gif";

# get_local_ipaddress()
sub get_local_ipaddress
{
	my $ipaddress = &to_ipaddress(get_system_hostname());
}

# Kill Emby related processes.
sub kill_emby_procs
{
	my $getembyprocs = 'pkill -U emby';
	my $killembyprocs = `$getembyprocs`;
}

sub get_emby_stats
{
	my %procs=();
	my $list=`ps -cxU emby | sed 1d | awk '{print \$5,\$1}'`;
	open my $fh, "<", \$list;
	while (my $line =<$fh>)
	{
		chomp ($line);
		my @props = split(" ", $line, 2);
		$ct = 1;
		foreach $prop (split(",", "Process")) {
			$procs{$props[0]}{$prop} = $props[$ct];
			$ct++;
		}
	}
	return %procs;
}

# Summary list.
sub ui_emby_stats
{
	my %procs = get_emby_stats($procs);
	@props = split(/,/, "Process");
	print &ui_columns_start([ "Service", "Command", "Process", "Status" ]);
	my $num = 0;
	foreach $key (sort(keys %procs))
	{
		@vals = ();
		foreach $prop (@props) { push (@vals, $procs{$key}{$prop}); }
		print &ui_columns_row(["<a href=$embyurl target=_blank>$text{'index_embystat'}</a>", "<a href='/proc/edit_proc.cgi?$procs{$key}{Process}'>$key</a>", @vals, "<img src=$okicon>" ]);
		$num ++;
	}
	print &ui_columns_end();
}

# restart_emby()
# Re-starts the Emby server, and returns an error message on failure or
# undef on success.
sub restart_emby
{
if ($config{'restart_cmd'}) {
	local $out = `$config{'restart_cmd'} 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);
	# Wait a sec for Emby service to populate.
	sleep (1);
	}
else {
	# Just kill Emby related processes and start Emby.
	kill_emby_procs;
	if ($config{'start_cmd'}) {
	$out = &backquote_logged("$config{'start_cmd'} 2>&1 </dev/null");
	if ($?) { return "<pre>$out</pre>"; }
	# Wait a sec for Emby service to populate.
	sleep (1);
		}
	}
return undef;
}

# stop_emby()
# Always use stop command whenever possible, otherwise
# try to kill the Emby server, returns an error message on failure or
# undef on success.
sub stop_emby
{
if ($config{'stop_cmd'}) {
	local $out = `$config{'stop_cmd'} 2>&1 </dev/null`;
	return "<pre>$out</pre>" if ($?);
	}
else {
	# Just kill Emby related processes.
	kill_emby_procs;
	}
return undef;
}

# start_emby()
# Attempts to start the Emby server, returning undef on success or an error
# message on failure.
sub start_emby
{
# Remove PID file if invalid.
if (-f $config{'pid_file'} && !&check_pid_file($config{'pid_file'})) {
	&unlink_file($config{'pid_file'});
	}
if ($config{'start_cmd'}) {
	$out = &backquote_logged("$config{'start_cmd'} 2>&1 </dev/null");
	if ($?) { return "<pre>$out</pre>"; }
	# Wait few secs for Emby services to populate.
	sleep (3);
	}
else {
	$out = &backquote_logged("$config{'emby_path'} 2>&1 </dev/null");
	if ($?) { return "<pre>$out</pre>"; }
	}
return undef;
}

# get_pid_file()
# Returns the Emby server PID file.
sub get_pid_file
{
	$pidfile = $config{'pid_file'};
	return $pidfile;
}

# get_emby_pid()
# Returns the PID of the running Emby process.
sub get_emby_pid
{
local $file = &get_pid_file();
if ($file) {
	return &check_pid_file($file);
	}
else {
	local ($rv) = &find_byname("emby");
	return $rv;
	}
}

1;
