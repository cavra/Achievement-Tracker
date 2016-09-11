#!/usr/bin/ruby

def main()
	commands = strip_input(ARGF.read)
	parse_commands(commands)
end

def strip_input(input)

	# Get each non-empty line
	commands = Array.new
  	input.each_line do |line|
    	if not line.nil? and line.strip.empty? then
   		else commands.push(line)
    	end
  	end
  	return commands
end

def parse_commands(commands)

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
		else printf("Invalid command: %s\n", command)
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
		print_line("Friends of " + @players[player_id][:player_name] + " who play " + @games[game_id][:game_name])
		printf("%-25s%-15s%-20s%-15s\n", "Friends who play", "Victories", "Gamerscore", "IGN")
		print_line()

		# Check if the data exists
		if lookup(@players, player_id, :friend_list).nil?
     		printf("\nPlayer with ID %s either doesn't exist, or they have no friends :(\n", player_id)
    	else
			# Check each friend to see if they play the game
			@players[player_id][:friend_list].each_with_index do |friend_id, index|
        		friend = @players[friend_id]

				friend_game_ids = friend[:game_list].keys
				friend_game_ids.each do |friend_game_id|

		        	if friend_game_id == game_id

						# Calculate the victory count
						player_victory_count = player_victory_count(friend_id, game_id)
						game_victory_count = game_victory_count(game_id)
						victory_count = player_victory_count.to_s + "/" + game_victory_count.to_s

						# Calculate the victory score
						player_victory_score = player_victory_score(friend_id, game_id)
						game_victory_score = game_victory_score(game_id)
						victory_score = player_victory_score.to_s + "/" + game_victory_score.to_s

						# Find the player's IGN
						player_ign = friend[:game_list][game_id][:player_ign]

						# Print the data
						printf("%-25s%-15s%-20s%-15s\n", "#{index + 1}. #{friend[:player_name]}", victory_count, victory_score, player_ign)
		        	end
		        end
        	end
      	end
      	print_line()
    end

  	def compare_players(command, player_id1, player_id2, game_id)

  		print_line("Player Comparison for " + @games[game_id][:game_name])

    	printf("Player 1: %s\n", @players[player_id1][:player_name])
    	print_comparison_data(player_id1, game_id)

    	printf("\nPlayer 2: %s\n", @players[player_id2][:player_name])
    	print_comparison_data(player_id2, game_id)
    
    end

	def print_comparison_data(player_id, game_id)
    	player = @players[player_id]
    	game = @games[game_id]

		printf("\n%-25s%-20s\n", "Victory Name", "Gamerscore")
		print_line()

		score = 0

    	if lookup(player, :game_list, game_id, :victory_list).nil?
				printf("%-25s%-20s\n", "No victories :(", 0)
    	else
      		# Loop through all the player's victories for the given game
			victory_ids = player[:game_list][game_id][:victory_list]
			victory_ids.each_with_index do |victory_id, index|

        		victory = @games[game_id][:victory_list][victory_id]

				printf("%-25s%-20s\n", "#{index + 1}. #{victory[:victory_name]}", victory[:victory_points])

		        score += (victory[:victory_points]).to_i
      		end
      	end
      	print_line()
		printf("%-25s%-20s\n", "Total victory score: ", score.to_s)
      	print_line()
    end

  	def summarize_player(command, player_id)

    	# Print the header
    	print_line("Summary of Player: " + @players[player_id][:player_name] + " (Player ID: " + player_id + ")")

		printf("Total Victory Score: %s points\n\n", total_victory_score(player_id))
		printf("%-25s%-15s%-20s%-15s\n", "Games", "Victories", "Gamerscore", "IGN")
		print_line()

		# Loop through each game
		game_ids = @players[player_id][:game_list].keys
		if game_ids.empty?
				printf("%-25s\n", "No Games :(")
      		print_line()
		else
			game_ids.each_with_index do |game_id, index|
	      		game = @games[game_id]

	      		# Calculate the victory count
	      		player_victory_count = player_victory_count(player_id, game_id)
	      		game_victory_count = game_victory_count(game_id)
	      		victory_count = player_victory_count.to_s + "/" + game_victory_count.to_s

	      		# Calculate the victory score
	      		player_victory_score = player_victory_score(player_id, game_id)
	      		game_victory_score = game_victory_score(game_id)
	      		victory_score = player_victory_score.to_s + "/" + game_victory_score.to_s

	      		# Find the player's IGN
	      		player_ign = @players[player_id][:game_list][game_id][:player_ign]

	      		# Print the data
				printf("%-25s%-15s%-20s%-15s\n", "#{index + 1}. #{game[:game_name]}", victory_count, victory_score, player_ign)
			end
      		print_line()
		end

		# Print the next header
		printf("\n%-25s%-15s\n", "Friends", "Total Gamerscore")
		print_line()

		# Loop through each friend
    	@players[player_id][:friend_list].each_with_index do |friend_id, index|
      		friend = @players[friend_id]

      		# Print the data
			printf("%-25s%-15s\n", "#{index + 1}. #{friend[:player_name]}", total_victory_score(friend_id))
    	end
      	print_line()
  	end

  	def summarize_game(command, game_id)
    
    	# Print the header
		print_line("Summary of Game: " + @games[game_id][:game_name] + " (Game ID: " + game_id + ")")
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

      		# Calculate the victory count
      		player_victory_count = player_victory_count(player_id, game_id)
      		game_victory_count = game_victory_count(game_id)
      		victory_count = player_victory_count.to_s + "/" + game_victory_count.to_s

      		# Calculate the victory score
      		player_victory_score = player_victory_score(player_id, game_id)
      		game_victory_score = game_victory_score(game_id)
      		victory_score = player_victory_score.to_s + "/" + game_victory_score.to_s

      		# Find the player's IGN
      		player_ign = player[:game_list][game_id][:player_ign]

      		# Print the data
			printf("%-25s%-15s%-20s%-15s\n", "#{index + 1}. #{player[:player_name]}", victory_count, victory_score, player_ign)
		end

		# Print the next header
		print_line()
		printf("\n%-25s%-15s%-20s\n", "Victories", "Points", "Times Achived")
		print_line()

		# Loop through each victory
		victory_ids = (@games[game_id][:victory_list]).keys
		victory_ids.each_with_index do |victory_id, index|
  			victory = @games[game_id][:victory_list][victory_id]

  			times_achieved = 0

      		players.each do |player_id|
      		player = @players[player_id]
      			if player[:game_list][game_id][:victory_list].include?(victory_id) then times_achieved += 1
      			end
      		end

      		# Print the data
      		printf("%-25s%-15s%-20s\n", "#{index + 1}. #{victory[:victory_name]}", victory[:victory_points], times_achieved)
      	end
		print_line()
  	end

  	# Print a list of all players who have achieved a Victory, and the percentage of players who play that game who have the Victory.
  	def summarize_victory(command, game_id, victory_id)
		victory = @games[game_id][:victory_list][victory_id]
		achieved_count = 0
		total_count = 0

		# Print the header
		print_line("Summary of Victory: " + victory[:victory_name] + " (Victory ID: " + victory_id + ")")
		printf("%-25s%-15s\n", "Achieved by", "IGN")
		print_line()

		# Loop through player database
		player_ids = @players.keys
		player_ids.each_with_index do |player_id, index|

			# If the player plays the game, increment the total count
			if !lookup(@players, player_id, :game_list, game_id).nil?
	      		total_count = total_count + 1

				# And if the player has achieved the victory, print their data
      			if @players[player_id][:game_list][game_id][:victory_list].include?(victory_id)
		      		achieved_count = achieved_count + 1
		      		player_ign = @players[player_id][:game_list][game_id][:player_ign]
					printf("%-25s%-15s\n", "#{achieved_count}. #{@players[player_id][:player_name]}", player_ign)
		      	end
		    end
		end
		print_line()

		percentage = (achieved_count.to_f / total_count.to_f) * 100
		
		printf("%i out of %i players have achieved this victory. (%i%%)\n", achieved_count, total_count, percentage)
		print_line()
  	end

  	# Print a summary ranking all players by their total number of gamer points.
  	def victory_ranking(command)

		# Print the header
		print_line("Victory Ranking Leaderboard")
		printf("%-25s%-15s\n", "Player", "Total Gamerscore")
		print_line()

		victory_scores = Hash.new

	  	player_ids = @players.keys
	  	player_ids.each do |player_id|

    		victory_scores.merge!({
  				player_id => (total_victory_score(player_id))
  			})
		end

		sorted = Hash[victory_scores.sort_by{|k,v| v}]

		player_ids = sorted.keys
		player_ids.each_with_index do |player_id, index|
  			printf("%-25s%-15i\n", "#{index + 1}. #{@players[player_id][:player_name]}", total_victory_score(player_id))
		end
		print_line()

	end

  	def print_line(*text)
    	if text.empty?
    		for i in 0..80
  				print("-")
  			end
  			print("\n")
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

  	def player_victory_count(player_id, game_id)
		if !@players[player_id][:game_list][game_id][:victory_list].nil?	
			return @players[player_id][:game_list][game_id][:victory_list].length
		else return 0
		end
	end

	def game_victory_count(game_id)
		if !@games[game_id][:victory_list].nil?
			return @games[game_id][:victory_list].length	
		else return 0
		end
	end

	#Unused
	def total_victory_count(player_id)
  		count = 0

  		# Loop through all of the player's games
  		if !@players[player_id][:game_list].nil?
  			game_ids = @players[player_id][:game_list].keys
  			game_ids.each do |game_id| 
		    	game = @games[game_id]

		    	count += player_victory_count(player_id, game_id)
			end
			return count
	    else return 0
	    end
	end

	def player_victory_score(player_id, game_id)
		score = 0

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

  		if !@games[game_id][:victory_list].nil?
	    	victory_ids = @games[game_id][:victory_list].keys
	    	victory_ids.each do |victory_id|
	    		score += (@games[game_id][:victory_list][victory_id][:victory_points]).to_i
	    	end
    		return score
		else return 0
		end
	end

  	def total_victory_score(player_id)
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

	# https://stackoverflow.com/questions/10130726/ruby-access-multidimensional-hash-and-avoid-access-nil-object
	def lookup(model, key, *rest) 
    	v = model[key]
    	if rest.empty?
    		v
    	else
    		v && lookup(v, *rest)
    	end
	end
end

main()