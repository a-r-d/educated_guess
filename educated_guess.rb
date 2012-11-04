#!/usr/bin/env ruby
#
#  educated_guess.rb
#  
#  Copyright 2012 ard <me@a-r-d.me>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  

#	Takes:
#	-s seedlist.txt
#	-p passlist.txt
#	-o outputname.txt
# 	
#	defaults:
#	-p = worst 500
#	-o = guesslist.txt

require 'optparse'

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: opt_parser COMMAND [OPTIONS]"
  opt.separator  ""
  opt.separator  "Example: educated_guess.rb full -o outp.txt -s seeds.txt -p worst500.txt"
  opt.separator  ""
  opt.separator  "Commands"
  opt.separator  "     full: Gives full slicing (all permutations), incorporates all birthdates, "
  opt.separator	 "			 common numbers, years, and other common password idioms"
  opt.separator  "	   common-with-list: Crosses pass list with seed list but does not do full" 
  opt.separator  "			 slicing, but will cross seed list with common numbers, birthdates, other idioms."
  opt.separator  "	   common: does not do full slicing, but will cross seed list with common numbers,"
  opt.separator  "   		   birthdates, other idioms. Wont cross seeds with pass list"
  opt.separator  "Options"

  opt.on("-s","--seed path/to/seedlist.txt","Seed list file, newline separated list of seed words") do |seed|
    options[:seed] = seed
  end

  opt.on("-p","--passlist path/to/passlist.txt", "password list file, newline seperated") do |pass|
    options[:pass] = pass
  end

  opt.on("-o","--output path/to/put/output.txt", "where the output file will go, newline seperated") do |out|
    options[:out] = out
  end
end

opt_parser.parse!

$type = 0

case ARGV[0]
when "common"
  puts "call common on options #{options.inspect}"
  $type = 3
when "full"
  puts "call full on options #{options.inspect}"
  $type = 1
when "common-with-list"
  puts "call common-with-list on options #{options.inspect}"
  $type = 2
else
  puts opt_parser
  $type = 0
end

#puts options
#puts options[:seed]

$seed_list = []
$seed_list_reverse = []
$pass_list = []
$out_list_temp = []

$total_written_counter = 0

$simple_num_list = ["0","1","2","3","4","5","6","7","8","9","10","77","69","777","666","00","123","12345","321"]
$simple_char_list = ["!", "$", "?", "asdf", "qwerty", ""]
$year_list = []
$short_year_list = []
$tenk_num_list = []

$out_file = options[:out]
$pass_file = options[:pass]
$seed_file = options[:seed]

if $out_file == nil || $out_file == ""
	$out_file = "guess_output.txt"
end

def open_list(file, arr)
	begin
		puts "......opening: #{file}"
		txt = File.open(file, "r").read
		txt.gsub!(/\r\n?/, "\n")
		txt.each_line { |line|
			temp = line.gsub!("\n", "")
			if not temp == nil
				temparr = temp.split(" ")
				temparr.each { |a| 
					arr << a
				}
			end
		}
		return true
	rescue Exception => e
		puts e.message
		return false
	end
end

## def mk seed list rev
def mk_seed_list_reverse(arr)
	arr.each { |a|
		r = a.reverse
		$seed_list_reverse << r
	}
end

#this is for common years only
def mk_year_list(arr)
	(1900..2020).each { |i|
		arr << "#{i}"
	}
end

#this is for 00-99
def mk_short_year_list(arr)
	temp_arr = []
	(0..99).each { |i|
		temp_arr << i
	}
	
	temp_arr.each { |i| 
		if( i < 10 )
			arr << "0#{i}"
		else
			arr << "#{i}"
		end
	}
end

# this is for pin numbers
def mk_tenk_list(arr)	
	(0..9999).each { |i| 
		if i < 10
			arr << "000#{i}"
		elsif i < 100
			arr << "00#{i}"
		elsif i < 1000
			arr << "0#{i}"
		else
			arr << "#{i}"
		end
	}
end

def process_lists
	## Open up the files:
	res = open_list($pass_file, $pass_list)
	if not res
		puts "failed to open pasword list"
		exit
	end
	l = $pass_list.length
	puts ".......length password list: #{l}"
	#@pass_list.each { |p| puts p }
	
	res = open_list($seed_file, $seed_list)
	if not res
		puts "failed to open seed list"
		exit
	end
	l = $seed_list.length
	puts ".......length of seed list #{l}"
	
	## generate nums we need:
	mk_year_list($year_list)
	mk_short_year_list($short_year_list)
	mk_tenk_list($tenk_num_list)
	mk_seed_list_reverse($seed_list)
end

# cross_simple
# input: takes two arrays and writes backward and forward combos of both a file ref.
#	* increments a counter
def cross_simple(arr1, arr2, file_ref)
	arr1.each { |outer| 
		arr2.each { |inner| 
			file_ref.puts("#{outer}#{inner}")
			file_ref.puts("#{inner}#{outer}")
			$total_written_counter += 2
		}
	}
end

# cross_three_in_ordeer
# input: takes 3 arrays and a file ref.
# writes: arr1[i] + arr2[i] + arr3[i]
# 	* increments a counter
def cross_three_in_order(arr1, arr2, arr3, file_ref)
	arr1.each { |a| 
		arr2.each { |b|
			arr3.each { |c| 
				file_ref.puts("#{a}#{b}#{c}")
				$total_written_counter += 1
			}
		}
	}
end

## Array 1 substrings cross with full words of 2nd arr
#  
#
def cross_arr1_permutations(arr1, arr2, file_ref)
	arr1.each { |a|
		temp_a_combos = []
		l = a.length
		
		(0...l).each { |i| 
			if i != l - 1
				temp_a_combos << a[0..i]
			end
		}
		
		temp_a_combos.each { |aa| 
			arr2.each { |a2| 
				file_ref.puts("#{a2}#{aa}")
				file_ref.puts("#{aa}#{a2}")
				$total_written_counter += 2
			}
		}
		
	}
end


def do_common
	puts "### Generating output list of complexity: COMMON: "
	begin
		f_ref = File.new($out_file, "w")
		$seed_list.each { |seed|
			f_ref.puts(seed)
			$total_written_counter += 1
		}
		$pass_list.each { |pass|
			f_ref.puts(pass)
			$total_written_counter += 1
		}
		
		cross_simple($seed_list, $pass_list, f_ref)
		cross_simple($seed_list, $simple_num_list, f_ref)
		cross_simple($seed_list, $simple_char_list, f_ref)
		
		cross_simple($seed_list, $year_list, f_ref)
		cross_simple($seed_list, $short_year_list, f_ref)
		
		#cross_three_in_order($seed_list, $pass_list, $simple_num_list, f_ref)
		
		puts "==============> Total length of guess list: #{$total_written_counter}"
		
		f_ref.close
	rescue Exception => e
		puts ""
		puts e.message
		puts "Failed to created list"
		puts ""
		exit
	end
end

def do_common_plus
	puts "### Not implemented yet: used 'full' or 'common' instead"
end

def do_full
	puts "### Generating output list of complexity: FULL: "
	begin
		f_ref = File.new($out_file, "w")
		$seed_list.each { |seed|
			f_ref.puts(seed)
			$total_written_counter += 1
		}
		$pass_list.each { |pass|
			f_ref.puts(pass)
			$total_written_counter += 1
		}
		
		cross_simple($seed_list, $pass_list, f_ref)
		cross_simple($seed_list, $simple_num_list, f_ref)
		cross_simple($seed_list, $simple_char_list, f_ref)
		
		cross_simple($seed_list_reverse, $pass_list, f_ref)
		cross_simple($seed_list_reverse, $simple_num_list, f_ref)
		cross_simple($seed_list_reverse, $simple_char_list, f_ref)
		
		cross_simple($seed_list, $tenk_num_list, f_ref)
		cross_simple($seed_list, $short_year_list, f_ref)
		cross_simple($seed_list_reverse, $short_year_list, f_ref)
		
		cross_three_in_order($seed_list, $pass_list, $simple_num_list, f_ref)
		cross_three_in_order($seed_list, $pass_list, $simple_char_list, f_ref)
		
		cross_arr1_permutations($seed_list, $pass_list, f_ref)
		
		puts "==============> Total length of guess list: #{$total_written_counter}"
		
		f_ref.close
	rescue Exception => e
		puts ""
		puts e.message
		puts "Failed to created list"
		puts ""
		exit
	end
end

## main routine:
process_lists
if $type == 1
	do_full
elsif $type == 2
	do_common_plus
elsif $type == 3
	do_common
else
	puts "Exiting- no valid command given"
end
