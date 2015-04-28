require 'yaml'

class Tile
  attr_reader :bomb, :revealed

  def initialize(bomb, board, position) #flagged and revealed variables?
    @revealed = false
    @flagged = false
    @bomb = bomb
    @board = board
    @position = position
  end

  def flag
    if @revealed
      false
    else
      @flagged ? @flagged = false : @flagged = true
      true
    end
  end

  def reveal
    if @revealed || @flagged
      false
    else
      @revealed = true
      if neighbors_bomb_count == 0
        neighbors.each do |neighbor|
          neighbor.reveal
        end
      end

      true
    end
  end

  def neighbors
    neighbors = []
    neighboring_coords = [[-1, 1],
                          [0, 1],
                          [1, 1],
                          [1, 0],
                          [1, -1],
                          [0, -1],
                          [-1, -1],
                          [-1, 0]]
    neighboring_spots = []
    neighboring_coords.each do |coords|
      neighboring_spots << [coords.first + @position.first,
                              coords.last + @position.last]
    end
    neighboring_spots.select! do |spot|
      spot.first.between?(0, 8) && spot.last.between?(0, 8)
    end

    neighboring_spots.each do |neighbor_pos|
      neighbors << @board.grid[neighbor_pos.first][neighbor_pos.last]
    end

    neighbors
  end

  def neighbors_bomb_count
    neighbors.count { |neighbor| neighbor.bomb }
  end

  def inspect
    if @revealed && neighbors_bomb_count.zero?
      print "_"
    elsif @revealed
      print "#{neighbors_bomb_count}"
    elsif @flagged
      print "F"
    elsif @board.over && @bomb
      print 'X'
    else
      print "*"
    end
  end
end

class Board
  attr_reader :num_bombs, :grid, :over

  def initialize(num_bombs)
    @grid = Array.new(9) { Array.new(9) }
    @num_bombs = num_bombs
    @over = false
  end

  def self.create_board(num_bombs)
    new_board = Board.new(num_bombs)
    # randomly pick out num_bombs coordinates
    pos = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    random_coords = []
    until random_coords.length == new_board.num_bombs
      random_pos = [pos.sample, pos.sample]

      random_coords << random_pos unless random_coords.include?(random_pos)
    end
    new_board.grid.each_index do |x|
      new_board.grid.each_index do |y|
        if random_coords.include?([x,y])
          new_board.grid[x][y] = Tile.new(true, new_board, [x,y])
        else
          new_board.grid[x][y] = Tile.new(false, new_board, [x,y])
        end
      end
    end
    new_board
  end

  # def play
  #   end_game_message = "You win"
  #   #temporary game loop
  #   until won?
  #     self.display
  #     coords = get_coords
  #     move = make_move(coords, get_mark)
  #
  #     if move == :lose
  #       end_game_message = "You lose"
  #       @over = true
  #       break
  #     end
  #   end
  #
  #   @over = true
  #   puts end_game_message
  #   display
  # end

  # def make_move(coords, mark)
  #   if mark == "F"
  #     grid[coords.first][coords.last].flag
  #   elsif mark == "R"
  #     return :lose if grid[coords.first][coords.last].bomb
  #     grid[coords.first][coords.last].reveal
  #   end
  # end

  # def won?
  #   num_revealed = 0
  #   @grid.each_index do |x|
  #     @grid.each_index do |y|
  #       num_revealed += 1 if @grid[x][y].revealed
  #     end
  #   end
  #   num_revealed == (@grid[0].length ** 2) - @num_bombs
  # end

  # def get_coords
  #   puts "Select a coordinate (row,col)"
  #   input = gets.chomp
  #   input.split(",").map(&:to_i)
  # end
  #
  # def get_mark
  #   puts "Flag or reveal? (F or R)"
  #   gets.chomp
  # end

  def display
    print "  "
    grid.each_index { |num| print " #{num} " }

    puts
    grid.each_index do |row|
      print " #{row} "
      grid[row].each do |tile|
        print " #{tile.inspect} "
      end
      puts
    end

    nil
  end
end

class Minesweeper
  def initialize(bombs)
    @board = Board.create_board(bombs)
  end

  def play
    end_game_message = "You win"
    #temporary game loop
    until won?
      @board.display
      coords = get_coords
      move = make_move(coords, get_mark)

      if move == :lose
        end_game_message = "You lose"

        break
      end
    end

    @board.over = true
    puts end_game_message
    display
  end

  def get_coords
    puts "Select a coordinate (row,col)"
    input = gets.chomp
    input.split(",").map(&:to_i)
  end

  def get_mark
    puts "Flag or reveal? (F or R)"
    gets.chomp
  end

  def make_move(coords, mark)
    if mark == "F"
      @board.grid[coords.first][coords.last].flag
    elsif mark == "R"
      return :lose if @board.grid[coords.first][coords.last].bomb
      @board.grid[coords.first][coords.last].reveal
    end
  end

  def won?
    num_revealed = 0
    @board.grid.each_index do |x|
      @board.grid.each_index do |y|
        num_revealed += 1 if @board.grid[x][y].revealed
      end
    end
    num_revealed == (@board.grid[0].length ** 2) - @board.num_bombs
  end

  def save_game(filename)
    File.open(filename, "w") do |f|
      f.puts self.to_yaml
    end
  end

  def self.load_game(filename)
    YAML.load_file(filename)
  end
end
# 
# if $PROGRAM_NAME == __FILE__
#   if ARGV[0].nil?
#     x = Minesweeper.new(10)
#     x.play
#   else
#     x = Minesweeper.load_game(ARGV[0])
#     x.play
#   end
# end
