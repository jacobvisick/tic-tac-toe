class Board

    def initialize
        # initialize arrays so we can use (x,y) coordinates directly
        # so we don't have to do fancy math
        @moves = [Array.new(4, " "), Array.new(4, " "), Array.new(4, " "), Array.new(4, " ")]

        @board = "   |   |    \n" \
                 "---+---+--- \n" \
                 "   |   |    \n" \
                 "---+---+--- \n" \
                 "   |   |    \n"
    end

    public
    def play_turn(player_team, x, y)
        return if is_move_taken?(x, y)
        update_board(player_team, x, y)
        check_wins
    end

    def display_board
        puts @board
    end

    def is_move_taken?(x, y)
        return @moves[x][y] != " "
    end

    private
    def update_board(player_team, x, y)

        @moves[x][y] = player_team

        #update board to just use (x,y) coordinates to avoid fancy math
        @board =  " #{@moves[1][3]} | #{@moves[2][3]} | #{@moves[3][3]} \n" \
                  "---+---+--- \n" \
                  " #{@moves[1][2]} | #{@moves[2][2]} | #{@moves[3][2]} \n" \
                  "---+---+--- \n" \
                  " #{@moves[1][1]} | #{@moves[2][1]} | #{@moves[3][1]}  \n"
    end
    
    def fake_win
        #just for testing
        @moves[1][1] = "x" 
        @moves[2][1] = "x"
        @moves[3][1] = "x"
    end

    def check_wins
        #return winning team if winner, else return nil

        #wins:
        # -- vert line --
        # (1,1)(1,2)(1,3)
        # (2,1)(2,2)(2,3)
        # (3,1)(3,2)(3,3)
        # -- horz line --
        # (1,1)(2,1)(3,1)
        # (1,2)(2,2)(3,2)
        # (1,3)(2,3)(3,3)
        # -- diag line --
        # (1,1)(2,2)(3,3)
        # (1,3)(2,2)(3,1)
        
        player_won = false
        winner = nil

        valid_wins = [ %w(11 12 13), %w(21 22 23), %w(31 32 33), 
                       %w(11 21 31), %w(12 22 32), %w(13 23 33),
                       %w(11 22 33), %w(13 22 31)]

        valid_wins.each do |win|
            x1 = win[0][0].to_i
            y1 = win[0][1].to_i
            x2 = win[1][0].to_i
            y2 = win[1][1].to_i
            x3 = win[2][0].to_i
            y3 = win[2][1].to_i

            if @moves[x1][y1] == @moves[x2][y2] && @moves[x2][y2] == @moves[x3][y3] &&
                @moves[x1][y1] != " " &&
                @moves[x2][y2] != " " &&
                @moves[x3][y3] != " "
                    player_won = true
                    winner = @moves[x1][y1]
            end
        end

        winner if player_won
    end

end

class Game

    def initialize(player_x, player_o)
        @player_x = {name: player_x, team: "X"}
        @player_o = {name: player_o, team: "O"}
        @current_player = @player_x
    end

    public
    def play_round
        gameIsWon = nil
        board = Board.new
        turns_played = 0
        
        while(!gameIsWon)
            # stop playing if there's a tie game
            break if turns_played >= 9

            # show current board before asking for moves
            board.display_board

            # get the next move from current player
            move = get_turn(@current_player)

            team = @current_player[:team]
            x = move[0].to_i
            y = move[1].to_i

            if board.is_move_taken?(x, y)
                puts "That spot has already been used!"
                next
            end

            # Board.play_turn returns nil unless there's a winner
            gameIsWon = board.play_turn(team, x, y)
            turns_played += 1
            break if gameIsWon

            # Swap current player before redoing loop
            @current_player == @player_x ? @current_player = @player_o : @current_player = @player_x
        end
        
        board.display_board

        if gameIsWon
            gameIsWon.upcase == "X" ? winner = @player_x[:name] : winner = @player_o[:name]
            game_won(winner)
        else
            tie_game
        end

    end


    private
    def get_turn(player)
        puts "#{player[:name]}'s ( #{player[:team]}'s ) turn. Enter your move:"
        
        isMoveValid = false
        move = ""
        while (!isMoveValid) do
            move = gets.chomp
            isMoveValid = validate_move(move)
            break if isMoveValid
            puts "#{move} isn't a valid input. Try again."
            puts "Use format 'x, y'"
        end

        move.delete(" ").delete(",").delete("'").delete('"')
    end

    def validate_move(move)
        #require 'pry-byebug'; binding.pry
        move = move.delete(" ").delete(",").delete("'").delete('"')
        return unless move.length == 2
        return unless move[0].to_i.between?(1, 3)
        return unless move[1].to_i.between?(1, 3)
        true
    end

    def tie_game
        puts "Out of moves. It's a tie!"
        puts "Better luck next time."
    end

    def game_won(winner)
        puts "Game over - #{winner} wins!"
    end
end

puts "Welcome to Tic-Tac-Toe!"
puts "Who will play X's?"
player_x = gets.chomp
player_x = "Player 1" if player_x.length == 0

puts "Who will play O's?"
player_o = gets.chomp
player_o = "Player 2" if player_o.length == 0

puts "#{player_x} vs #{player_o}"

game = Game.new(player_x, player_o)

puts "Enter your moves as coordinates on board 'x, y'"
puts "For example, for the top left corner, enter '1, 3'"
game.play_round