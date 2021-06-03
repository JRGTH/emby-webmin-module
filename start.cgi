#!/usr/local/bin/perl
# start.cgi
# Start the Emby daemon

require './emby-lib.pl';
&ReadParse();
&error_setup($text{'start_err'});
$err = &start_emby();
&error($err) if ($err);
&webmin_log("start");
&redirect("");
