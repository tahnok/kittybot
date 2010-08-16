#!/usr/bin/perl -w

#This is kittybot v1.0 by Wesley Ellis (aka tahnok) of tahnok AT gmail .com
#This perl script requires LWP::Simple, Bot::BasicBot, XML::RSS::Parser::Lite
# and WWW::Shorten
#
#To use set $Nick, $Server, and $Channel
#
#Released under CC attribution-shareAlike
# http://creativecommons.org/licenses/by-sa/2.5/
#
#Bugs:
##I don't think multi channel actually works... haven't bothered checking


use warnings;
use strict;

package MyBot;
use base qw( Bot::BasicBot );
use LWP::Simple;
use WWW::Shorten 'TinyURL';
use XML::RSS::Parser::Lite;


my $Channel = "#mcgill";
my $Server = "irc.freenode.net";
my $Nick = "kittybot";


	sub said {      
		my ($self, $message) = @_;
		my $strings = $message->{body};
  		my $counter = 0;
		if( $message->{channel}  eq "msg") {
			if ( $message->{who} eq 'tahnok'){
				$self->say(channel=>$Channel, body=>$strings,);
			}
		}
	  	$strings = "\n" . $strings . "\n";
	 	if( $strings =~ /!geoip/) {
			my $nikk = $message->{raw_nick};
			my $url = "";
			if( $nikk =~ m/(.*)(@)(.*)$/ ) {
				$url = $3;
			}
			if ( $url =~ m/.+\//){
				return 'Error: user has a hostmask';
			}
			if($url !~ m/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/){
				use Socket;
	        		$url = inet_ntoa(inet_aton($url));
			}
			my $geoip = 'http://geoip.pidgets.com?ip=' . $url . '&format=[xml]';
			my $content = get $geoip;
      			my $result = "";
			if( $content =~ m/<city>(.+)<.{1}city>/) {
				$result = $1;
			}
			if( $content =~ m/<region>(.+)<.{1}region>/) {
				$result = $result . ", " . $1;
			}
			if ($result eq  ""){
				return "No valid Location information found";
			}
			my $longurl = "";
			if( $content =~ m/<latitude>(.+)<.{1}latitude>/) {
				$longurl = "http://maps.google.com/maps?f=d&source=s_d&saddr=" . $1;
			 }
			if( $content =~ m/<longitude>(.+)<.{1}longitude>/) {
				$longurl = $longurl . "," . $1;
			}
			my $shorturl = makeashorterlink($longurl);
			$result = $result . ", " . $shorturl;
			return $result;
		}
		if ($strings =~ /!die/ ) {
			if ( $message->{who} eq "tahnok") {
				exit;
			}
			else{
				return "har har nice try";
			}
		}
		if ($strings =~ /kitty!/ ){
			return kitty();
		}
		if ($strings =~ /!kitty/ ) {
			return kitty();
		}
	}

# help text for the bot
	sub help { "I'm annoying, and do nothing useful." }

	sub connected {
		my $self = shift;
		$self->say(
			channel => $Channel, 
			body => "meow",
		);
	}

	sub tick{
		my $self = shift;
		$self->say(
			channel => $Channel,
			body => "Random kitty: " . kitty(),
		);
		
		return 43200;
	}
	sub kitty {
		my $xml = get("http://api.flickr.com/services/feeds/photos_public.gne?tags=kitty&lang=en-us&format=rss_200");
        	my $rp = new XML::RSS::Parser::Lite;
        	$rp->parse($xml);
        	my $choice = int(rand($rp->count()));
        	my $it = $rp->get($choice);
        	if(int(rand(10)) != 9){
			return $it->get('title') . " " . makeashorterlink($it->get('url')) . "\n";	
		}
		else{
			return $it->get('title') . " " . makeashorterlink("http://www.youtube.com/watch?v=oHg5SJYRHA0");
		}
		}
# Create an instance of the bot and start it running. Connect
# to the main perl IRC server, and join some channels.
	MyBot->new(
		server => $Server,
		channels => [ $Channel],
		nick => $Nick, 
		name => 'Secretly a goose',
	)->run();
