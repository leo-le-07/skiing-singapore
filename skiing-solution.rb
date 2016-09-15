class Elevation
  attr_accessor :position, :parent, :value, :weight, :root

  def initialize(row, column, value)
    @position = Array.new
    @position.push(row).push(column)
    @value = value
    @parent = nil
    @root = nil
    @weight = 1
  end
end

class Skii
  def initialize
    @arr_input = Array.new
    @arr_sorted = Array.new
    @hash_visited = Hash.new
    @hash_elevations = Hash.new
    @key_weightest = nil
  end

  def load_input(file_name)
    File.foreach(file_name).with_index do |line, index|
      arr = line.split.map(&:to_i)
      if index == 0
        @arr_row = arr[0]
        @arr_column = arr[1]
      else
        @arr_input.push(arr)
      end
    end
  end

  def sort_arr_input_by_topology
    start = Time.now
    @arr_input.each_with_index do |x, idx_row|
      x.each_with_index do |cell, idx_col|
        if unvisited?(idx_row, idx_col)
          visit(idx_row, idx_col)
        end
      end
    end
    finish = Time.now
    puts "Sorting time #{finish - start}"
  end

  def visit(i, j)
    @hash_visited[gen_key(i, j)] = 1
    if (j > 0 && @arr_input[i][j-1] < @arr_input[i][j] && unvisited?(i, j-1))
      visit(i, j-1)
    end
    if (i < @arr_row - 1 && @arr_input[i+1][j] < @arr_input[i][j] && unvisited?(i+1, j))
      visit(i+1, j)
    end
    if (j < @arr_column - 1 && @arr_input[i][j+1] < @arr_input[i][j] && unvisited?(i, j+1))
      visit(i, j+1)
    end
    if (i > 0 && @arr_input[i-1][j] < @arr_input[i][j] && unvisited?(i-1, j))
      visit(i-1, j)
    end
    tmp = Array.new
    tmp.push(i).push(j).push(@arr_input[i][j])
    @arr_sorted.push(tmp)
  end

  def unvisited?(i, j)
    !@hash_visited.has_key?(gen_key(i, j))
  end

  def gen_key(i, j)
    "#{i}-#{j}"
  end

  def find_longest_deeper_path
    @arr_sorted.reverse_each do |e|
      elevation = Elevation.new(e[0], e[1], e[2])
      weightest_elevation = weightest_elevation_around(elevation)
      elevation.parent = weightest_elevation
      unless weightest_elevation.nil?
        elevation.weight = weightest_elevation.weight + 1
        elevation.root = weightest_elevation.root
      else
        elevation.root = elevation
      end
      @hash_elevations[gen_key(elevation.position[0], elevation.position[1])] = elevation
      
      update_key_weightest(elevation)
    end
  end

  def update_key_weightest(elevation)
    current_key = gen_key(elevation.position[0], elevation.position[1])
    if ((@key_weightest.nil?) ||
        (!@key_weightest.nil? && @hash_elevations[current_key].weight > @hash_elevations[@key_weightest].weight) ||
        (!@key_weightest.nil? && @hash_elevations[current_key].weight == @hash_elevations[@key_weightest].weight &&
           (@hash_elevations[current_key].root.value - @hash_elevations[current_key].value) > (@hash_elevations[@key_weightest].root.value - @hash_elevations[@key_weightest].value)))
      @key_weightest = current_key
    end
  end

  def weightest_elevation_around(elevation)
    i = elevation.position[0]
    j = elevation.position[1]
    weightest_elevation = nil

    weightest_elevation = get_weightest_elevation(weightest_elevation, elevation, [i, j-1])
    weightest_elevation = get_weightest_elevation(weightest_elevation, elevation, [i+1, j])
    weightest_elevation = get_weightest_elevation(weightest_elevation, elevation, [i, j+1])
    weightest_elevation = get_weightest_elevation(weightest_elevation, elevation, [i-1, j])

    weightest_elevation
  end

  def get_weightest_elevation(weightest_elevation, elevation, position)
    if (@hash_elevations.has_key?(gen_key(position[0], position[1])) && @hash_elevations[gen_key(position[0], position[1])].value > elevation.value)
      compared_elevation = @hash_elevations[gen_key(position[0], position[1])]
      
      if (weightest_elevation.nil?) ||
        (!weightest_elevation.nil? && weightest_elevation.weight < compared_elevation.weight) ||
        (!weightest_elevation.nil? && weightest_elevation.weight == compared_elevation.weight && weightest_elevation.value < compared_elevation.value)
        weightest_elevation = compared_elevation
      end
    end
    weightest_elevation
  end

  def run
    start = Time.now
    sort_arr_input_by_topology()
    find_longest_deeper_path()
    finish = Time.now
    puts "Time finding: #{finish - start}"

    print_result()
    #print_longest_path()
    #print_arr_topo()
    #print_hash_elevation()
  end

  private
    def print_arr_topo
      @arr_sorted.each do |val|
        puts "#{val[2]} (#{val[0]}, #{val[1]})"
      end
    end

    def print_result
      result_str = ""
      #puts @hash_elevations[@key_weightest].root.value
      #puts @hash_elevations[@key_weightest].value
      puts "#{@hash_elevations[@key_weightest].root.value.to_i - @hash_elevations[@key_weightest].value.to_i } #{@hash_elevations[@key_weightest].weight}"
    end

    def print_hash_elevation
      @hash_elevations.each do |key, value|
        puts "#{key} => #{value.value} (#{value.position[0]}, #{value.position[1]}) : #{value.weight}"
      end
    end

    def print_longest_path
      result_str = ""
      start_elevation = @hash_elevations[@key_weightest]
      while start_elevation != nil do
        result_str.prepend("#{start_elevation.value} ")
        start_elevation = start_elevation.parent
      end
      puts result_str
    end
end

skii = Skii.new
skii.load_input("input.txt")
skii.run
