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
    else
      commands.push(line)
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
    else puts("Invalid command: " + command)
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
    new_player = {
      :player_name => player_name,
      :game_list => Hash.new,
      :friend_list => Array.new
    }

    @players[player_id] = new_player
  end

  def add_game(command, game_id, game_name)
    new_game = {
      :game_name => game_name,
      :victories => Hash.new
    }

    @games[game_id] = new_game
  end

  def add_victory(command, game_id, victory_id, victory_name, victory_points)
    new_victory = {
      victory_id => {
        :victory_name => victory_name, 
        :victory_points => victory_points
      }
    }

    # Alternate method, better?
    #@games[game_id][:victories].update(new_victory)
    (@games[game_id][:victories]).merge!(new_victory)
  end

  def plays(command, player_id, game_id, player_ign)
    new_game_list = {
      game_id => {
        :player_ign => player_ign
      }
    }

    (@players[player_id][:game_list]).merge!(new_game_list)
  end

  def add_friends(command, player_id1, player_id2)
    player1 = get_object("player", player_id1, nil)
    player2 = get_object("player", player_id2, nil)

    player1[:friend_list].push(player_id2)
    player2[:friend_list].push(player_id1)
  end

  def win_victory(command, player_id, game_id, victory_id)
    victory = get_object("victory", game_id, victory_id)

    (@players[player_id][:game_list][game_id]).merge!({
      :victories => {
        victory_id => victory
      }
    })
  end

  def friends_who_play(command, player_id, game_id)
    player = get_object("player", player_id, nil)
    
    if player.nil? or player[:friend_list].nil?
      puts("Player with ID " + player_id + " either doesn't exist or has no friends")
    else
      player[:friend_list].each do |friend_id|
        friend = get_object("player", friend_id, nil)

        player_game_list = player[:game_list].keys
        friend_game_list = player[:game_list].keys

        player_game_list.each do |player_game|
          friend_game_list.each do |friend_game|

            if player_game == friend_game
              game = get_object("game", player_game, nil)
              puts(player[:player_name] + " and " + friend[:player_name] + " both play " + game[:game_name])
            end
          end
        end
      end
    end
  end

  def compare_players(command, player_id1, player_id2, game_id)
    player1 = get_object("player", player_id1, nil)
    player2 = get_object("player", player_id2, nil)
    
    game = get_object("game", game_id, nil)

    puts("Comparison of " + player1[:player_name] + " and " + player2[:player_name] + " on " + game[:game_name])
    if player1[:game_list][game_id][:victories].nil?
      puts(player1[:player_name] + " has no victories for this game")
    else
      score = 0
      puts(player1[:player_name] + "'s victories for this game: ")
      victory_ids = (player1[:game_list][game_id][:victories]).keys
      victory_ids.each do |victory_id|
        victory = get_object("victory", game_id, victory_id)  
        puts("Victory name: " + victory[:victory_name])
        puts("Victory points: " + victory[:victory_points])
        score += (victory[:victory_points]).to_i
      end
      puts("Total victory score: " + score.to_s)
    end

    if player2[:game_list][game_id][:victories].nil?
      puts(player2[:player_name] + " has no victories for this game")
    else
      score = 0
      puts(player2[:player_name] + "'s victories for this game: ")
      victory_ids = (player2[:game_list][game_id][:victories]).keys
      victory_ids.each do |victory_id|
        victory = get_object("victory", game_id, victory_id)
        puts("Victory name: " + victory[:victory_name])
        puts("Victory points: " + victory[:victory_points])
        score += (victory[:victory_points]).to_i
      end
      puts("Total victory score: " + score.to_s)
    end

  end

  def summarize_player(command, player_id)
    player = get_object("player", player_id, nil)

    puts("Summary of player: " + player[:player_name])
    puts("Player ID: " + player_id)

    puts("Plays: ")
    game_ids = player[:game_list].keys
    game_ids.each do |game_id| 
      game = get_object("game", game_id, nil)
      puts(game[:game_name])

      if player[:game_list][game_id][:victories].nil?
        puts("No victories for this game")
      else
        puts("Victories for this game: ")
        victory_ids = (player[:game_list][game_id][:victories]).keys
        victory_ids.each do |victory_id|
          victory = get_object("victory", game_id, victory_id)  
          puts(victory[:victory_name])
        end
      end
    end

    puts("Friends: ")
    player[:friend_list].each do |friend_id|   
      friend = get_object("player", friend_id, nil)
      puts(friend[:player_name])
    end
  end

  def summarize_game(command, game_id)
    game = get_object("game", game_id, nil)
    
    puts("Summary of game: " + game[:game_name])
    puts("Game ID: " + game_id)
  end

  def summarize_victory(command, game_id, victory_id)
    victory = get_object("victory", game_id, victory_id)

    puts("Summary of victory: " + victory[:victory_name])
    puts("Victory ID: " + victory_id)
    puts("Victory Points: " + victory[:victory_points])
  end

  def victory_ranking(command)

  end

  def get_object(type, id, id2)
    case type
    when "player" then return (@players[id])
    when "game" then return (@games[id])
    when "victory" then return (@games[id][:victories][id2])
    end
  end

end

main()