#!/usr/bin/ruby

def main()

	# Read in the standard input
	input = ARGF.read

	# Get each non-empty line
	commands = Array.new
  	input.each_line do |line|
    	if !line.nil? and line.strip.empty? then 
   		else commands.push(line)
    	end
  	end

	leaderboard = Leaderboard.new()

	# Parse each line and execute the valid ones
	commands.each do |command|

		# Get the arguments using regex
		# https://stackoverflow.com/questions/8162444/ruby-regex-extracting-words
		args = command.scan(/\s*("([^"]+)"|\w+)\s*/).map { |match| match[1].nil? ? match[0] : match[1] }

		result = case [args[0], args.length]
		when ["AddPlayer", 3] then leaderboard.add_player(*args)
		when ["AddGame", 3] then leaderboard.add_game(*args)
		when ["AddVictory", 5] then leaderboard.add_victory(*args)
		when ["Plays", 4] then leaderboard.plays(*args)
		when ["AddFriends", 3] then leaderboard.add_friends(*args)
		when ["WinVictory", 4] then leaderboard.win_victory(*args)
		when ["FriendsWhoPlay", 3] then leaderboard.friends_who_play(*args)
		when ["ComparePlayers", 4] then leaderboard.compare_players(*args)
		when ["SummarizePlayer", 2] then leaderboard.summarize_player(*args)
		when ["SummarizeGame", 2] then leaderboard.summarize_game(*args)
		when ["SummarizeVictory", 3] then leaderboard.summarize_victory(*args)
		when ["VictoryRanking", 1] then leaderboard.victory_ranking(*args)
		else printf("Invalid command: #{command}")
		end
	end
end

class Leaderboard
	@players
	@games

	def initialize()
		@players = Hash.new
		@games = Hash.new
	end

	def add_player(command, player_id, player_name)
		@players[player_id] = {
			:player_name => player_name,
			:game_list => Hash.new,
			:friend_list => Array.new
		}
	end

	def add_game(command, game_id, game_name)
  		@games[game_id] = {
			:game_name => game_name,
			:victory_list => Hash.new
    	}
  	end

  	def add_victory(command, game_id, victory_id, victory_name, victory_points)
  		@games[game_id][:victory_list][victory_id] = {
	  		:victory_name => victory_name, 
	  		:victory_points => victory_points
  		}
  	end

  	def plays(command, player_id, game_id, player_ign)
  		@players[player_id][:game_list][game_id] = {
  			:player_ign => player_ign,
  			:victory_list => Array.new
    	}
  	end

  	def add_friends(command, player_id1, player_id2)
    	@players[player_id1][:friend_list].push(player_id2)
    	@players[player_id2][:friend_list].push(player_id1)
  	end

  	def win_victory(command, player_id, game_id, victory_id)
    	@players[player_id][:game_list][game_id][:victory_list].push(victory_id)
	end

  	def friends_who_play(command, player_id, game_id)

  		# Print the header
		print_line("Friends of #{@players[player_id][:player_name]} who play #{@games[game_id][:game_name]}")
		printf("%-25s%-15s%-20s%-15s\n", "Friends who play", "Victories", "Gamerscore", "IGN")
		print_line()

		# Check if the data exists
		if lookup(@players, player_id, :friend_list).nil?
     		print("\nPlayer with ID #{player_id} either doesn't exist, or they have no friends :(\n")
    	else
			# Check each friend's game library to see if they play the game
			@players[player_id][:friend_list].each_with_index do |friend_id, index|
				friend_game_ids = @players[friend_id][:game_list].keys
				if friend_game_ids.include?(game_id)

					player_name = "#{index + 1}. #{@players[friend_id][:player_name]}"
		      		victory_count = "#{@players[friend_id][:game_list][game_id][:victory_list].length}/#{@games[game_id][:victory_list].length}"
		      		victory_score = "#{player_victory_score(friend_id, game_id)}/#{game_victory_score(game_id)} pts"
		      		player_ign = @players[friend_id][:game_list][game_id][:player_ign]

		      		# Use format specifiers to print the data
					printf("%-25s%-15s%-20s%-15s\n", player_name, victory_count, victory_score, player_ign)
		        end
        	end
      	end
      	print_line()
    end

  	def compare_players(command, player_id1, player_id2, game_id)

  		# Print the header
  		print_line("Player Comparison for #{@games[game_id][:game_name]}")

    	print("Player 1: #{@players[player_id1][:player_name]} (Player ID: #{player_id1})")
    	print_comparison_data(player_id1, game_id)

    	print("\nPlayer 2: #{@players[player_id2][:player_name]} (Player ID: #{player_id2})")
    	print_comparison_data(player_id2, game_id)
    end

	def print_comparison_data(player_id, game_id)

  		# Print the header
		printf("\n\n%-25s%-20s\n", "Victory Name", "Victory Points")
		print_line()

		total_score = 0

		# Check if the data exists
    	if lookup(@players[player_id], :game_list, game_id, :victory_list).nil?
				print("No victories :(\n")
    	else
      		# Loop through all the player's victories for the given game
			victory_ids = @players[player_id][:game_list][game_id][:victory_list]
			victory_ids.each_with_index do |victory_id, index|

				victory_name = "#{index + 1}. #{@games[game_id][:victory_list][victory_id][:victory_name]}"
        		victory_points = "#{@games[game_id][:victory_list][victory_id][:victory_points]} pts"
		        total_score += (@games[game_id][:victory_list][victory_id][:victory_points]).to_i

				printf("%-25s%-20s\n", victory_name, victory_points)
      		end
      	end
      	print_line()
		printf("%-25s%-20s\n", "Total Gamerscore: ", "#{total_score} pts")
      	print_line()
    end

  	def summarize_player(command, player_id)

    	# Print the header
    	print_line("Summary of Player: #{@players[player_id][:player_name]} (Player ID: #{player_id})")
		printf("Total Gamerscore: #{calculate_gamerscore(player_id)} points\n\n")
		printf("%-25s%-15s%-20s%-15s\n", "Games", "Victories", "Gamerscore", "IGN")
		print_line()

		# Loop through each game
		game_ids = @players[player_id][:game_list].keys
		if game_ids.empty?
				printf("No Games :(\n")
      		print_line()
		else
			game_ids.each_with_index do |game_id, index|
	      		game = @games[game_id]

	      		game_name = "#{index + 1}. #{game[:game_name]}"
		      	victory_count = "#{@players[player_id][:game_list][game_id][:victory_list].length}/#{@games[game_id][:victory_list].length}"
	      		victory_score = "#{player_victory_score(player_id, game_id)}/#{game_victory_score(game_id)} pts"
	      		player_ign = @players[player_id][:game_list][game_id][:player_ign]

				printf("%-25s%-15s%-20s%-15s\n", game_name, victory_count, victory_score, player_ign)
			end
      		print_line()
		end

		# Print the next header
		printf("\n%-25s%-15s\n", "Friends", "Total Gamerscore")
		print_line()

		# Loop through each friend
    	@players[player_id][:friend_list].each_with_index do |friend_id, index|
      		friend = @players[friend_id]

      		friend_name = "#{index + 1}. #{friend[:player_name]}"
      		total_gamerscore = "#{calculate_gamerscore(friend_id)} pts"

			printf("%-25s%-15s\n", friend_name, total_gamerscore)
    	end
      	print_line()
  	end

  	def summarize_game(command, game_id)
    
    	# Print the header
		print_line("Summary of Game: #{@games[game_id][:game_name]} (Game ID: #{game_id})")
		printf("%-25s%-15s%-20s%-15s\n", "Players", "Victories", "Gamerscore", "IGN")
		print_line()

		players = Array.new

		# Loop through player database
		player_ids = @players.keys
		player_ids.each do |player_id|

			# If the player plays the game, record them
			if @players[player_id][:game_list].key?(game_id)
				players.push(player_id)
			end
		end

		# Loop through each player
		players.each_with_index do |player_id, index|
      		player = @players[player_id]

      		player_name = "#{index + 1}. #{player[:player_name]}"
		    victory_count = "#{@players[player_id][:game_list][game_id][:victory_list].length}/#{@games[game_id][:victory_list].length}"
      		victory_score = "#{player_victory_score(player_id, game_id)}/#{game_victory_score(game_id)} pts"
      		player_ign = @players[player_id][:game_list][game_id][:player_ign]

			printf("%-25s%-15s%-20s%-15s\n", player_name, victory_count, victory_score, player_ign)
		end

		# Print the next header
		print_line()
		printf("\n%-25s%-15s%-20s\n", "Victories", "Prize", "Times Achieved")
		print_line()

		# Loop through each victory
		victory_ids = (@games[game_id][:victory_list]).keys
		victory_ids.each_with_index do |victory_id, index|

  			times_achieved = 0

      		players.each do |player_id|
      			if @players[player_id][:game_list][game_id][:victory_list].include?(victory_id) then times_achieved += 1
      			end
      		end

      		victory_name = "#{index + 1}. #{@games[game_id][:victory_list][victory_id][:victory_name]}"
      		victory_points = "#{@games[game_id][:victory_list][victory_id][:victory_points]} pts"

      		printf("%-25s%-15s%-20s\n", victory_name, victory_points, times_achieved)
      	end
		print_line()
  	end

  	def summarize_victory(command, game_id, victory_id)
		achieved_count = 0
		total_count = 0

		# Print the header
		print_line("Summary of Victory: #{@games[game_id][:victory_list][victory_id][:victory_name]} (Victory ID: #{victory_id})")
		print("Game: #{@games[game_id][:game_name]}\n\n")
		printf("%-25s%-15s\n", "Achieved by", "IGN")
		print_line()

		# Loop through player database
		player_ids = @players.keys
		player_ids.each_with_index do |player_id, index|

			# If the player plays the game, increment the total count
			if @players[player_id][:game_list].key?(game_id)
	      		total_count = total_count + 1

				# And if the player has achieved the victory, print their data
      			if @players[player_id][:game_list][game_id][:victory_list].include?(victory_id)
		      		
		      		achieved_count = achieved_count + 1
		      		player_name = "#{achieved_count}. #{@players[player_id][:player_name]}"
		      		player_ign = @players[player_id][:game_list][game_id][:player_ign]

					printf("%-25s%-15s\n", player_name, player_ign)
		      	end
		    end
		end
		print_line()

		percentage = (achieved_count.to_f / total_count.to_f) * 100
		
		print("#{achieved_count} out of #{total_count} players have achieved this victory (#{percentage}%)\n")
		print_line()
  	end

  	def victory_ranking(command)

		# Print the header
		print_line("Victory Ranking Leaderboard")
		printf("%-25s%-15s\n", "Player", "Total Gamerscore")
		print_line()

		victory_scores = Hash.new

	  	player_ids = @players.keys
	  	player_ids.each do |player_id|

    		victory_scores.merge!({
  				player_id => (calculate_gamerscore(player_id))
  			})
		end

		sorted = Hash[victory_scores.sort_by{|k,v| v}]

		player_ids = sorted.keys
		player_ids.each_with_index do |player_id, index|

			player_name = "#{index + 1}. #{@players[player_id][:player_name]}"
			total_gamerscore = "#{calculate_gamerscore(player_id)} pts"

  			printf("%-25s%-15s\n", player_name, total_gamerscore)
		end
		print_line()

	end

	# Helper functions
	def player_victory_score(player_id, game_id)
		score = 0
  		# Loop through all of the player's games
		if !@players[player_id][:game_list][game_id][:victory_list].nil?
		    victory_ids = @players[player_id][:game_list][game_id][:victory_list]
			victory_ids.each do |victory_id|
		    	score += (@games[game_id][:victory_list][victory_id][:victory_points]).to_i
		    end
		    return score
		else return 0
		end
	end

  	def game_victory_score(game_id)
  		score = 0
  		# Loop through all of the player's games
  		if !@games[game_id][:victory_list].nil?
	    	victory_ids = @games[game_id][:victory_list].keys
	    	victory_ids.each do |victory_id|
	    		score += (@games[game_id][:victory_list][victory_id][:victory_points]).to_i
	    	end
    		return score
		else return 0
		end
	end

  	def calculate_gamerscore(player_id)
  		score = 0
  		# Loop through all of the player's games
  		if !@players[player_id][:game_list].nil?
  			game_ids = @players[player_id][:game_list].keys
  			game_ids.each do |game_id| 
		    	game = @games[game_id]

		    	score += player_victory_score(player_id, game_id)
			end
			return score
	    else return 0
	    end
	end

	def print_line(*text)
		# Print a line 80 characters long if no text is supplied
    	if text.empty?
    		for i in 0..80
  				print("-")
  			end
  			print("\n")
  		# Otherwise, create a header with 2 lines and text in the middle
    	else
  			print("\n")
    		print_line()
    		for i in 0..10
    			print("-")
    		end
  			printf(" %s\n", text)
  			print_line()
    		print("\n")
    	end
	end

	# https://stackoverflow.com/questions/10130726/ruby-access-multidimensional-hash-and-avoid-access-nil-object
	def lookup(model, key, *rest) 
    	v = model[key]
    	# Return the value if only one key is supplied
    	if rest.empty?
    		v
    	# Otherwise, call recursively until a value or nil is reached
    	else
    		v && lookup(v, *rest)
    	end
	end
end

main()