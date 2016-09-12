class Skii
  def initialize
    @arr = Array.new
    @arr_result = Array.new
    load_input()
  end

  def load_input
    File.foreach("input.txt").with_index do |line, index|
      if index == 0
        @arr_row = line.split[0].to_i
        @arr_column = line.split[1].to_i
      else
        @arr.push(line.split)
      end
    end
  end

  def ski
    @arr.each_with_index do |x, idx_row|
      x.each_with_index do |cell, idx_col|
        arr_cell = Array.new
        visit(idx_row, idx_col, arr_cell)
      end
    end
  end

  def visit(i, j, arr_cell)
    if (j > 0 && @arr[i][j - 1] < @arr[i][j])
      
    end
  end
end
