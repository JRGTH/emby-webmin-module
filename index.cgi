#!/usr/local/bin/perl
# index.cgi
# Display Emby option categories

require './emby-lib.pl';

# Check if config file exists.
if (!-r $config{'emby_config'}) {
	&ui_print_header(undef, $text{'index_title'}, "", "intro", 1, 1);
	print &text('index_econfig', "<tt>$config{'emby_config'}</tt>",
		"$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
	&ui_print_footer("/", $text{"index"});
	exit;
	}

# Check if Emby exists.
if (!&has_command($config{'emby_path'})) {
	&ui_print_header(undef, $text{'index_title'}, "", "intro", 1, 1);
	print &text('index_eemby', "<tt>$config{'emby_path'}</tt>",
		"$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
	&ui_print_footer("/", $text{"index"});
	exit;
	}

# Get Emby version.
my $version = &get_emby_version();
if (!$config{'version_cmd'} == "blank") {
	# Display version.
	&write_file("$module_config_directory/version", {""},$version);
	&ui_print_header(undef, $text{'index_title'}, "", "intro", 1, 1, 0,
		&help_search_link("emby", "man", "doc", "google"), undef, undef,
		&text('index_version', "$text{'index_modver'} $version"));
	}
else {
	# Don't display version.
	&ui_print_header(undef, $text{'index_title'}, "", "intro", 1, 1, 0,
		&help_search_link("emby", "man", "doc", "google"), undef, undef,
		&text('index_version', ""));
}

# Get Emby status.
my $embystatus = &get_emby_stats();

# Get local ip address.
my $ipaddress =  &get_local_ipaddress();

# Configure Emby ip address.
if (!$config{'emby_url'} == "blank") {
	# Set the user defined ip.
	$embyurl = "$config{'emby_url'}";
	}
else {
	# Set the system local ip.
	$embyurl = "http://$ipaddress:8096/web";
}

#print &ui_columns_start([$text{'index_colitem'}, $text{'index_colinfo'}, $text{'index_colstat'}]);
# Display informative column if service is running.
if (!$embystatus == "blank") {
	print &ui_tabs_start_tab("mode", "info");
	&ui_emby_stats();
	print &ui_tabs_end_tab("mode", "info");
	}
print &ui_columns_end();

# Check if Emby is running.
$pid = &get_emby_pid();
print &ui_hr();
print &ui_buttons_start();
if ($pid) {
	# Running .. offer to restart and stop.
	print &ui_buttons_row("stop.cgi", $text{'index_stop'}, $text{'index_stopmsg'});
	print &ui_buttons_row("restart.cgi", $text{'index_restart'}, $text{'index_restartmsg'});
	}
else {
	# Not running .. offer to start.
	print &ui_buttons_row("start.cgi", $text{'index_start'}, $text{'index_startmsg'});
	}
print &ui_buttons_end();

&ui_print_footer("/", $text{"index"});
