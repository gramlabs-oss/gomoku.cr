require "io"
require "./types"

module Gomoku
  VERSION = "0.1.0-dev"

  # 五子棋棋局生成器
  class Builder
    getter victory_coords : Array(Int32)
    getter board : Array(Array(CellColor))

    def initialize(@size : Int = 15)
      # 生成二维棋盘
      @board = Array(Array(CellColor)).new
      @size.times.each do
        @board.push (0..@size - 1).map { CellColor::None }
      end
      @victory_coords = [0, 0]
    end

    # 生成棋局，只剩下最后一步即可成功
    def make
      # 随机生成胜利方向（四选一）
      @direction = Direction.new(Random.rand(0..3))

      # 根据方向限制坐标随机范围
      coord_ranges =
        case @direction
        when Direction::Up
          {0...@size, 4...@size}
        when Direction::Down
          {0...@size, 0...(@size - 4)}
        when Direction::Left
          {4...@size, 0...@size}
        when Direction::Right
          {0...(@size - 4), 0...@size}
        else
          {0, 0}
        end
      # 随机生成横纵坐标
      x_range, y_range = coord_ranges
      x_seed = Random.rand(x_range)
      y_seed = Random.rand(y_range)
      # 种子坐标置为黑色
      @board[y_seed][x_seed] = CellColor::Black
      # 确定胜利坐标（单向，使用白子堵截其一）

      # 随机堵截位置（二选一）
      off_n = Random.rand(0..1)
      # 胜利位置（堵截的相对位置）
      victory_n = 1 - off_n
      case @direction
      when Direction::Up
        if (y_seed - 4) >= 0 && y_seed < (@size - 1) # 非靠边
          # 植白棋坐标
          double_victory_c = [[y_seed - 4, x_seed], [y_seed + 1, x_seed]]
          white_c = double_victory_c[off_n]
          @board[white_c[0]][white_c[1]] = CellColor::White
          @victory_coords = double_victory_c[victory_n]
        else
          @victory_coords = [y_seed - 4, x_seed] if y_seed == (@size - 1)
          @victory_coords = [y_seed + 1, x_seed] if (y_seed - 4) == 0
        end
      when Direction::Down
        if (y_seed + 4) < @size && y_seed > 0 # 非靠边
          # 植白棋坐标
          double_victory_c = [[y_seed + 4, x_seed], [y_seed - 1, x_seed]]
          white_c = double_victory_c[off_n]
          @board[white_c[0]][white_c[1]] = CellColor::White
          @victory_coords = double_victory_c[victory_n]
        else
          @victory_coords = [y_seed + 4, x_seed] if y_seed == 0
          @victory_coords = [y_seed - 1, x_seed] if (y_seed + 4) == (@size - 1)
        end
      when Direction::Left
        if (x_seed - 4) >= 0 && x_seed < (@size - 1) # 非靠边
          # 植白棋坐标
          double_victory_c = [[y_seed, x_seed - 4], [y_seed, x_seed + 1]]
          white_c = double_victory_c[off_n]
          @board[white_c[0]][white_c[1]] = CellColor::White
          @victory_coords = double_victory_c[victory_n]
        else
          @victory_coords = [y_seed, x_seed - 4] if x_seed == (@size - 1)
          @victory_coords = [y_seed, x_seed + 1] if (x_seed - 4) == 0
        end
      when Direction::Right
        if (x_seed + 4) < @size && x_seed > 0 # 非靠边
          # 植白棋坐标
          double_victory_c = [[y_seed, x_seed + 4], [y_seed, x_seed - 1]]
          white_c = double_victory_c[off_n]
          @board[white_c[0]][white_c[1]] = CellColor::White
          @victory_coords = double_victory_c[victory_n]
        else
          @victory_coords = [y_seed, x_seed + 4] if x_seed == 0
          @victory_coords = [y_seed, x_seed - 1] if (x_seed + 4) == (@size - 1)
        end
      else
        {0, 0}
      end

      @board.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          case @direction
          when Direction::Up
            if x_seed == x                      # 位于同一列
              if y > (y_seed - 4) && y < y_seed # 位于胜利方向
                @board[y][x] = CellColor::Black
              end
            end
          when Direction::Down
            if x_seed == x                      # 位于同一列
              if y < (y_seed + 4) && y > y_seed # 位于胜利方向
                @board[y][x] = CellColor::Black
              end
            end
          when Direction::Left
            if y_seed == y                      # 位于同一行
              if x < x_seed && x > (x_seed - 4) # 位于胜利方向
                @board[y][x] = CellColor::Black
              end
            end
          when Direction::Right
            if y_seed == y                      # 位于同一行
              if x > x_seed && x < (x_seed + 4) # 位于胜利方向
                @board[y][x] = CellColor::Black
              end
            end
          end
        end
      end
      self
    end

    def print
      puts "@direction: #{@direction}"
      @board.each do |row|
        io = IO::Memory.new
        row.each_with_index do |cell, i|
          symbol =
            case cell
            when CellColor::White
              "○"
            when CellColor::Black
              "●"
            else
              " "
            end
          io << "|" if i == 0
          io << symbol
          io << "|"
        end
        puts io.to_s
      end
    end
  end
end
