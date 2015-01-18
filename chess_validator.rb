#encoding: utf-8
require 'pry'
require 'pp'

BOARD_SIZE = 8
# binding.pry


class Controller
	def self.start(board_filename, moves_filename)
		# First we create all the instances of pieces storing all its data (even position)
		pieces_arr = Parser.parse_board(board_filename)
		# Then we print the initial state of the board
		pp "Initial state of the board: "
		draw_table(pieces_arr)
		# And then we process the movements file and store the results. The result is an array containing LEGAL / ILLEGAL
		checked_movements = Movements.process_movements(moves_filename, pieces_arr)
	end

	private
	def self.draw_table(pieces_arr)
		temp_table = []
		BOARD_SIZE.times do |actual_row|
			temp_row = []
			BOARD_SIZE.times do |actual_column|
				# Check in every position if there's any piece
				possible_piece = Checks.check_position(pieces_arr, actual_column, actual_row)
				if possible_piece != nil
					# Puts the piece data on this temp_table position
					temp_row <<  possible_piece.piece_type + possible_piece.team
				else
					# Insert "--" on this temp_table position
					temp_row << "--"
				end
			end
			temp_table << temp_row
		end
		pp temp_table
	end
end

class Checks
	def self.valid_position?(position, pieces_arr)
		(0..BOARD_SIZE).each do |pos_x|
			(0..BOARD_SIZE).each do |pos_y|
				pieces_arr.each do |actual_piece|
					if (actual_piece.position == [pos_x, pos_y])
						return false
					end
				end
			end
		end
		true	
	end

	def self.check_board_size?(x,y)
		(x < BOARD_SIZE) && (y < BOARD_SIZE)
	end

	# This class returns the piece on that position
	def self.check_position(pieces_arr, column, row)
		pieces_arr.each do |actual_piece|
			if (actual_piece.position == [column, row])
				return actual_piece
			end
		end
		return nil
	end

	def self.check_movement(initial_position, final_position, pieces_arr)
		# First we check the initial position
		initial_position = PositionParser.to_cartesian(initial_position)
		initial_checking = check_position(pieces_arr, initial_position[0], initial_position[1])
		pp initial_checking
	end
end

class PositionParser
	def self.to_cartesian(position)
		case position[0].to_s
		when "a" then return [0, position[1]]
		when "b" then return [1, position[1]]
		when "c" then return [2, position[1]]
		when "d" then return [3, position[1]]
		when "e" then return [4, position[1]]
		when "f" then return [5, position[1]]
		when "g" then return [6, position[1]]
		when "h" then return [7, position[1]]
		end
	end

	def self.to_chess(position)
		case position[0]
		when 0 then return ["a", position[1]]
		when 1 then return ["b", position[1]]
		when 2 then return ["c", position[1]]
		when 3 then return ["d", position[1]]
		when 4 then return ["e", position[1]]
		when 5 then return ["f", position[1]]
		when 6 then return ["g", position[1]]
		when 7 then return ["h", position[1]]
		end
	end
end

class Piece

	attr_accessor :position, :team, :piece_type

	def initialize(position, team, piece_type)
		@position = position
		@team = team
		@piece_type = piece_type
	end
end

class Pawn
	def self.check_movement?(new_x, new_y)
	# 	# Need to check if new_x and new_y is a valid position
	end
end

class Knight
	def self.check_movement?(new_x, new_y)
	end
end

class Bishop
	def self.check_movement?(new_x, new_y)
		x_diff = (new_x - @position[0]).abs
		y_diff = (new_y - @position[1]).abs
		
		check_board_size(new_x, new_y) && (x_diff == y_diff)
	end
end

class Rook
	def self.check_movement?(new_x, new_y)
		(@position[0] == new_x || @position[1] == new_y) # && NO HAY OTRA PIEZA EN EL CAMINO NI EN EL FINAL MEDIO, la del final mirar antes de llamar!! si es de tu equipo, no si es del otro, SI!!!!! MATAAA
	end
end

class Queen
	def self.check_movement?(new_x, new_y)
	end
end

class King
	def self.check_movement?(new_x, new_y)
	end
end

class Movements
	# COMPROBAR SI EL MOVIMIENTO ESTA DENTRO DE LOS LIMITES!! AQUI!! SINO, DESCARTAR DIRECTAMENTE EL MOVIMIENTO
	def self.process_movements(moves_filename, pieces_arr)
		movements_str = IO.read(moves_filename)
		# Here we could check the presence of movements data before processing it - ASSUMED
		movements = movements_str.split("\n")
		# Output is an array containing LEGAL / ILLEGAL depending on the movements
		output = []
		movements.each do |actual_movement|
			initial_position = actual_movement.split(" ")[0]
			final_position = actual_movement.split(" ")[1]
			# This is supposed to return LEGAL / ILLEGAL
			binding.pry
			output << Checks.check_movement(initial_position, final_position, pieces_arr)
		end
		output
	end
end

# bR bN bB bQ bK bB bN bR
# bP bP bP bP bP bP bP bP
# -- -- -- -- -- -- -- --
# -- -- -- -- -- -- -- --
# -- -- -- -- -- -- -- --
# -- -- -- -- -- -- -- --
# wP wP wP wP wP wP wP wP
# wR wN wB wQ wK wB wN wR

class Parser
	def self.parse_board(board_filename)
		# return ARRAY DE PIEZAS
		pieces_arr = []
		row_count = 0

		initial_table = IO.read(board_filename)
		initial_table.split("\n").each do |table_row|
			parse_line(table_row, row_count, pieces_arr)
			# pieces_arr << parse_line(table_row, row_count)
			row_count += 1
		end
		pieces_arr
	end
 
	private
	def self.parse_line(table_row, row_count, pieces_arr)
		column_count = 0

		table_row.split(" ").each do |piece_acronym|
			if (piece_acronym != "--")
				position = [column_count, row_count]
				temp = Piece.new(position, piece_acronym[1], piece_acronym[0])
				# Little trick
				if temp != nil
					pieces_arr << temp
				end
			end
			column_count += 1
		end
	end
end

# class PieceFactory
# 	def self.get_piece(position, type, team)
# 		case type
# 		when "R" then Rook.new(position, team)
# 		when "N" then Knight.new(position, team)
# 		when "B" then Bishop.new(position, team)
# 		when "Q" then Queen.new(position, team)
# 		when "K" then King.new(position, team)
# 		end
# 	end
# end

# Controller.start("simple_board.txt")
Controller.start("simple_board.txt", "simple_moves.txt")
# pp PositionParser.to_cartesian(["a",2])
# pp PositionParser.to_cartesian(["b",8])
# pp PositionParser.to_cartesian(["c",6])