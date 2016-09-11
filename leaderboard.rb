class Leaderboard

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Initialize the class with two hashes, the chosen data structure.
  #   @players will contain all data relating to the players. Likewise, 
  #   @games will contain all data relating to the games.
  def initialize
    @players = {}
    @games = {}
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Add player to the database. 
  #   <Player ID> is a positive integer identifier for the player. 
  #   <Player Name> is a string enclosed by double quotes ("Andruid Kerne"). 
  #   <Player Name> may contain special characters (excluding double quote).
  def add_player(command, player_id, player_name)
    @players[player_id] = {
      :player_name => player_name,
      :game_list => {},
      :friend_list => [],
      :gamerscore => 0
    }
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Add game to the database. 
  #   <Game ID> is a positive integer identifier for the game. 
  #   <Game Name> is a string enclosed by double quotes (i.e. "Mirror's Edge"). 
  #   <Game Name> may contain special characters (excluding double quote).
  def add_game(command, game_id, game_name)
    @games[game_id] = {
      :game_name => game_name,
      :victory_list => {},
      :possible_points => 0
    }
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Add Victory to the game denoted by <Game ID>. 
  #   <Victory ID> is an integer identifier for the Victory. 
  #   <Victory Name> is a string enclosed by double quotes 
  #     (i.e. "Head over heels"). 
  #   <Victory Name> may contain special characters (excluding double quote). 
  #   <Victory Points> is an integer indicating how many gamer points the 
  #     Victory is worth.
  def add_victory(command, game_id, victory_id, victory_name, victory_points)
    @games[game_id][:victory_list][victory_id] = {
      :victory_name => victory_name, 
      :victory_points => victory_points
    }

    # Update the game's total points available
    @games[game_id][:possible_points] += victory_points.to_i
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Add entry for player playing a specific game. 
  #   <Player IGN> is a string identifier for that that player's particular 
  #     in game name for the specified game, enclosed by double quotes. 
  #   <Player IGN> may contain special characters (excluding double quote).
  def plays(command, player_id, game_id, player_ign)
    @players[player_id][:game_list][game_id] = {
      :player_ign => player_ign,
      :victory_list => [],
      :game_score => 0
    }
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Makes players 1 & 2 friends. Friends are mutual.
  def add_friends(command, player_id1, player_id2)
    @players[player_id1][:friend_list].push(player_id2)
    @players[player_id2][:friend_list].push(player_id1)
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Adds Victory indicated to <Player ID>'s record. Each Victory can only be 
  #   achieved by a given player for once.
  def win_victory(command, player_id, game_id, victory_id)
    @players[player_id][:game_list][game_id][:victory_list].push(victory_id)
    
    #Update the player's total gamerscore and their specified game score
    victory_points = @games[game_id][:victory_list][victory_id][:victory_points].to_i
    @players[player_id][:gamerscore] += victory_points
    @players[player_id][:game_list][game_id][:game_score] += victory_points
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Report which of player's friends play the specified game.
  def friends_who_play(command, player_id, game_id)
    # Print the report header
    print_line("Friends of #{@players[player_id][:player_name]} who play #{@games[game_id][:game_name]}")
    printf("%-25s%-15s%-20s%-15s\n", "Friends who play", "Victories", "Gamerscore", "IGN")
    print_line

    # Check if the specified player has friends
    if @players[player_id][:friend_list].empty? then
      print("Player with ID #{player_id} doesn't have any friends :(\n")
    else
      # Check each friend's game library to see if they play the game
      @players[player_id][:friend_list].each_with_index do |friend_id, index|
        if @players[friend_id][:game_list].keys.include?(game_id)

          # Format the data into string variables
          player_name = "#{index + 1}. #{@players[friend_id][:player_name]}"
          victory_count = "#{@players[friend_id][:game_list][game_id][:victory_list].size}/#{@games[game_id][:victory_list].size}"
          victory_score = "#{@players[friend_id][:game_list][game_id][:game_score]}/#{@games[game_id][:possible_points]} pts"
          player_ign = @players[friend_id][:game_list][game_id][:player_ign]

          # Use format specifiers to print the formatted data
          printf("%-25s%-15s%-20s%-15s\n", player_name, victory_count, victory_score, player_ign)
        end
      end
    end
    print_line
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Print report comparing player 1 and player 2's Victory records and total 
  #   Victory scores for the given game. The given game is guaranteed to have 
  #   been played by both players.
  def compare_players(command, player_id1, player_id2, game_id)
    # Print the report header
    print_line("Player Comparison for #{@games[game_id][:game_name]}")

    print("Player 1: #{@players[player_id1][:player_name]} (Player ID: #{player_id1})")
    print_comparison_data(player_id1, game_id)

    print("\nPlayer 2: #{@players[player_id2][:player_name]} (Player ID: #{player_id2})")
    print_comparison_data(player_id2, game_id)
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Print record of all of player's friends, games the player plays, and gamer 
  #   point totals.
  def summarize_player(command, player_id)
    # Print the report header
    print_line("Summary of Player: #{@players[player_id][:player_name]} (Player ID: #{player_id})")
    printf("Total Gamerscore: #{@players[player_id][:gamerscore]} points\n\n")
    printf("%-25s%-15s%-20s%-15s\n", "Games", "Victories", "Gamerscore", "IGN")
    print_line

    # Firstly, check if the player plays any games
    if @players[player_id][:game_list].keys.empty?
      printf("No Games :(\n")
      print_line
    else
      # For each game found, print its data
      @players[player_id][:game_list].keys.each_with_index do |game_id, index|

        # Format the data into string variables
        game_name = "#{index + 1}. #{@games[game_id][:game_name]}"
        victory_count = "#{@players[player_id][:game_list][game_id][:victory_list].size}/#{@games[game_id][:victory_list].size}"
        victory_score = "#{@players[player_id][:game_list][game_id][:game_score]}/#{@games[game_id][:possible_points]} pts"
        player_ign = @players[player_id][:game_list][game_id][:player_ign]

        # Use format specifiers to print the formatted data
        printf("%-25s%-15s%-20s%-15s\n", game_name, victory_count, victory_score, player_ign)
      end
      print_line
    end

    # Print the second header
    printf("\n%-25s%-15s\n", "Friends", "Total Gamerscore")
    print_line

    # For each friend, print their data
    @players[player_id][:friend_list].each_with_index do |friend_id, index|

      # Format the data into string variables
      friend_name = "#{index + 1}. #{@players[friend_id][:player_name]}"
      total_gamerscore = "#{@players[friend_id][:gamerscore]} pts"

      # Use format specifiers to print the formatted data
      printf("%-25s%-15s\n", friend_name, total_gamerscore)
    end
    print_line
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Print a record of all players who play the specified game and the number 
  #   of times each of its victories have been accomplished.
  def summarize_game(command, game_id)
    # Print the report header      
    print_line("Summary of Game: #{@games[game_id][:game_name]} (Game ID: #{game_id})")
    printf("%-25s%-15s%-20s%-15s\n", "Players", "Victories", "Gamerscore", "IGN")
    print_line

    # For each player, store their id if they play the specified game
    players = []
    @players.each_key do |player_id|
      players.push(player_id) if @players[player_id][:game_list].key?(game_id) 
    end

    # For each player_id stored, print its data
    players.each_with_index do |player_id, index|
      player = @players[player_id]

      # Format the data into string variables
      player_name = "#{index + 1}. #{player[:player_name]}"
      victory_count = "#{@players[player_id][:game_list][game_id][:victory_list].size}/#{@games[game_id][:victory_list].size}"
      victory_score = "#{@players[player_id][:game_list][game_id][:game_score]}/#{@games[game_id][:possible_points]} pts"
      player_ign = @players[player_id][:game_list][game_id][:player_ign]

      # Use format specifiers to print the formatted data
      printf("%-25s%-15s%-20s%-15s\n", player_name, victory_count, victory_score, player_ign)
    end

    # Print the second header
    print_line
    printf("\n%-25s%-15s%-20s\n", "Victories", "Points", "Times Achieved")
    print_line

    # For each victory id
    @games[game_id][:victory_list].keys.each_with_index do |victory_id, index|

      # Keep track of how many players have achieved the victory
      times_achieved = 0
      players.each do |player_id|
        times_achieved += 1 if @players[player_id][:game_list][game_id][:victory_list].include?(victory_id) 
      end

      # Format the data into string variables
      victory_name = "#{index + 1}. #{@games[game_id][:victory_list][victory_id][:victory_name]}"
      victory_points = "#{@games[game_id][:victory_list][victory_id][:victory_points]} pts"

      # Use format specifiers to print the formatted data
      printf("%-25s%-15s%-20s\n", victory_name, victory_points, times_achieved)
    end
    print_line
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Print a list of all players who have achieved a Victory, and the 
  #   percentage of players who play that game who have the Victory.
  def summarize_victory(command, game_id, victory_id)
    # Print the report header      
    print_line("Summary of Victory: #{@games[game_id][:victory_list][victory_id][:victory_name]} (Victory ID: #{victory_id})")
    print("Game: #{@games[game_id][:game_name]}\n\n")
    printf("%-25s%-15s\n", "Achieved by", "IGN")
    print_line

    achieved_player_count = 0
    total_player_count = 0

    # For each player id...
    @players.keys.each_with_index do |player_id, index|

      # If the player plays the specified game...
      if @players[player_id][:game_list].key?(game_id)
        total_player_count = total_player_count + 1

        # If they also have achieved the specified victory...
        if @players[player_id][:game_list][game_id][:victory_list].include?(victory_id)
          achieved_player_count = achieved_player_count + 1

          # Format the data into string variables
          player_name = "#{achieved_player_count}. #{@players[player_id][:player_name]}"
          player_ign = @players[player_id][:game_list][game_id][:player_ign]

          # Use format specifiers to print the formatted data
          printf("%-25s%-15s\n", player_name, player_ign)
        end
      end
    end
    percentage = (achieved_player_count.to_f / total_player_count.to_f) * 100

    print_line
    print("#{achieved_player_count} out of #{total_player_count} players have achieved this victory (#{percentage}%)\n")
    print_line
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Print a summary ranking all players by their total number of gamer points.
  def victory_ranking
    # Print the report header
    print_line("Victory Ranking Leaderboard")
    printf("%-25s%-15s\n", "Player", "Total Gamerscore")
    print_line

    # For each player, store their ID and total gamerscore in a temporary Hash
    victory_scores = {}
    @players.each_key do |player_id|
      victory_scores.merge!( { player_id => @players[player_id][:gamerscore].to_i } )
    end

    # Sort the hash and print the data
    sorted_player_ids = Hash[victory_scores.sort_by { |_k, v| v } ]
    sorted_player_ids.keys.each_with_index do |player_id, index|

      # Format the data into string variables
      player_name = "#{index + 1}. #{@players[player_id][:player_name]}"
      total_gamerscore = "#{@players[player_id][:gamerscore]} pts"

      # Use format specifiers to print the formatted data
      printf("%-25s%-15s\n", player_name, total_gamerscore)
    end
    print_line
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Helper function to print all data for a player from the comparison method
  def print_comparison_data(player_id, game_id)
    # Print the header
    printf("\n\n%-25s%-20s\n", "Victory Name", "Victory Points")
    print_line

    # Check if the player has any victories for the specified game
    if @players[player_id][:game_list][game_id][:victory_list].empty?
      print("No victories :(\n")
    else
      # Loop through all the player's victories for the given game
      @players[player_id][:game_list][game_id][:victory_list].each_with_index do |victory_id, index|

        # Format the data into string variables
        victory_name = "#{index + 1}. #{@games[game_id][:victory_list][victory_id][:victory_name]}"
        victory_points = "#{@games[game_id][:victory_list][victory_id][:victory_points]} pts"

        # Use format specifiers to print the formatted data
        printf("%-25s%-20s\n", victory_name, victory_points)
      end
    end
    print_line
    printf("%-25s%-20s\n", "Total Gamerscore: ", "#{@players[player_id][:gamerscore]} pts")
    print_line
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # If text is supplied as a paramter, it prints a header with 2 lines and text 
  #   in the middle. Otherwise, it just prints a line 80 characters long. 
  def print_line(*text)
    if text.empty?
      80.times { print("-") }
    else
      print("\n")
      print_line
      10.times { print("-") }
      printf(" %s\n", text)
      print_line
    end
    print("\n")
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end