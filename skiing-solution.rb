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
    @input_arr = Array.new
    @sorted_arr = Array.new
    @visited_elevations = Hash.new
    @key_weightest = nil
  end

  def load_input(file_name)
    File.foreach(file_name).with_index do |line, index|
      arr = line.split.map(&:to_i)
      if index == 0
        @arr_row = arr[0]
        @arr_column = arr[1]
      else
        @input_arr.push(arr)
      end
    end
  end

  def sort_array
    start = Time.now
    (0..@arr_row - 1).each do |r|
      (0..@arr_column - 1).each do |c|
        @sorted_arr.push([r, c])
      end
    end

    @sorted_arr.sort_by! {|e| -@input_arr[e[0]][e[1]]}
    finish = Time.now
    puts "Sorting time: #{finish - start}"
  end

  def gen_key(i, j)
    "#{i}-#{j}"
  end

  def find_path
    start = Time.now
    @sorted_arr.each do |coord|
      r = coord[0]
      c = coord[1]
      elevation = Elevation.new(r, c, @input_arr[r][c])
      weightest_elevation = weightest_elevation_around(elevation)
      elevation.parent = weightest_elevation
      unless weightest_elevation.nil?
        elevation.weight = weightest_elevation.weight + 1
        elevation.root = weightest_elevation.root
      else
        elevation.root = elevation
      end
      @visited_elevations[gen_key(elevation.position[0], elevation.position[1])] = elevation
      
      update_key_weightest(elevation)
    end
    finish = Time.now
    puts "Finding time: #{finish - start}"
  end

  def update_key_weightest(elevation)
    current_key = gen_key(elevation.position[0], elevation.position[1])
    if ((@key_weightest.nil?) ||
        (!@key_weightest.nil? && @visited_elevations[current_key].weight > @visited_elevations[@key_weightest].weight) ||
        (!@key_weightest.nil? && @visited_elevations[current_key].weight == @visited_elevations[@key_weightest].weight &&
           (@visited_elevations[current_key].root.value - @visited_elevations[current_key].value) > (@visited_elevations[@key_weightest].root.value - @visited_elevations[@key_weightest].value)))
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
    if (@visited_elevations.has_key?(gen_key(position[0], position[1])) && @visited_elevations[gen_key(position[0], position[1])].value > elevation.value)
      compared_elevation = @visited_elevations[gen_key(position[0], position[1])]
      
      if (weightest_elevation.nil?) ||
        (!weightest_elevation.nil? && weightest_elevation.weight < compared_elevation.weight) ||
        (!weightest_elevation.nil? && weightest_elevation.weight == compared_elevation.weight && weightest_elevation.value < compared_elevation.value)
        weightest_elevation = compared_elevation
      end
    end
    weightest_elevation
  end

  def run
    sort_array()
    find_path()

    print_result()
    print_longest_path()
    #print_sorted_arr()
    #print_hash_elevation()
  end

  private
    def print_sorted_arr
      @arr_sorted.each do |val|
        puts "#{val[2]} (#{val[0]}, #{val[1]})"
      end
    end

    def print_result
      result_str = ""
      #puts @visited_elevations[@key_weightest].root.value
      #puts @visited_elevations[@key_weightest].value
      puts "#{@visited_elevations[@key_weightest].root.value.to_i - @visited_elevations[@key_weightest].value.to_i } #{@visited_elevations[@key_weightest].weight}"
    end

    def print_hash_elevation
      @visited_elevations.each do |key, value|
        puts "#{key} => #{value.value} (#{value.position[0]}, #{value.position[1]}) : #{value.weight}"
      end
    end

    def print_longest_path
      result_str = ""
      start_elevation = @visited_elevations[@key_weightest]
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
